/*
Copyright 2025.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controller

import (
	"context"
	"fmt"

	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/util/intstr"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	todoappv1 "github.com/frobware/sample-konflux-app/api/v1"
)

// TodoAppReconciler reconciles a TodoApp object
// This change should only trigger operator builds due to CEL expression filtering
type TodoAppReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

// +kubebuilder:rbac:groups=apps.todoapp.io,resources=todoapps,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=apps.todoapp.io,resources=todoapps/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=apps.todoapp.io,resources=todoapps/finalizers,verbs=update
// +kubebuilder:rbac:groups=apps,resources=deployments,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups="",resources=services,verbs=get;list;watch;create;update;patch;delete

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
func (r *TodoAppReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	logger := log.FromContext(ctx)

	// Fetch the TodoApp instance
	todoApp := &todoappv1.TodoApp{}
	err := r.Get(ctx, req.NamespacedName, todoApp)
	if err != nil {
		if errors.IsNotFound(err) {
			logger.Info("TodoApp resource not found, ignoring since object must be deleted")
			return ctrl.Result{}, nil
		}
		logger.Error(err, "Failed to get TodoApp")
		return ctrl.Result{}, err
	}

	// Set default values
	if todoApp.Spec.Image == "" {
		todoApp.Spec.Image = "nginx:latest"
	}
	if todoApp.Spec.Replicas == nil {
		replicas := int32(1)
		todoApp.Spec.Replicas = &replicas
	}
	if todoApp.Spec.Port == 0 {
		todoApp.Spec.Port = 8080
	}

	// Create or update Deployment
	deployment := r.deploymentForTodoApp(todoApp)
	err = r.createOrUpdateDeployment(ctx, deployment, todoApp)
	if err != nil {
		logger.Error(err, "Failed to create or update Deployment")
		return ctrl.Result{}, err
	}

	// Create or update Service
	service := r.serviceForTodoApp(todoApp)
	err = r.createOrUpdateService(ctx, service, todoApp)
	if err != nil {
		logger.Error(err, "Failed to create or update Service")
		return ctrl.Result{}, err
	}

	// Update status
	err = r.updateStatus(ctx, todoApp)
	if err != nil {
		logger.Error(err, "Failed to update status")
		return ctrl.Result{}, err
	}

	return ctrl.Result{}, nil
}

// deploymentForTodoApp creates a Deployment for the TodoApp
func (r *TodoAppReconciler) deploymentForTodoApp(todoApp *todoappv1.TodoApp) *appsv1.Deployment {
	labels := map[string]string{
		"app":     "todoapp",
		"todoapp": todoApp.Name,
	}

	deployment := &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{
			Name:      todoApp.Name,
			Namespace: todoApp.Namespace,
			Labels:    labels,
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: todoApp.Spec.Replicas,
			Selector: &metav1.LabelSelector{
				MatchLabels: labels,
			},
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: labels,
				},
				Spec: corev1.PodSpec{
					Containers: []corev1.Container{{
						Name:  "todoapp",
						Image: todoApp.Spec.Image,
						Ports: []corev1.ContainerPort{{
							ContainerPort: todoApp.Spec.Port,
							Name:          "http",
						}},
					}},
				},
			},
		},
	}

	ctrl.SetControllerReference(todoApp, deployment, r.Scheme)
	return deployment
}

// serviceForTodoApp creates a Service for the TodoApp
func (r *TodoAppReconciler) serviceForTodoApp(todoApp *todoappv1.TodoApp) *corev1.Service {
	labels := map[string]string{
		"app":     "todoapp",
		"todoapp": todoApp.Name,
	}

	service := &corev1.Service{
		ObjectMeta: metav1.ObjectMeta{
			Name:      todoApp.Name,
			Namespace: todoApp.Namespace,
			Labels:    labels,
		},
		Spec: corev1.ServiceSpec{
			Selector: labels,
			Ports: []corev1.ServicePort{{
				Port:       80,
				TargetPort: intstr.FromInt32(todoApp.Spec.Port),
				Protocol:   corev1.ProtocolTCP,
			}},
		},
	}

	ctrl.SetControllerReference(todoApp, service, r.Scheme)
	return service
}

// createOrUpdateDeployment creates or updates the Deployment
func (r *TodoAppReconciler) createOrUpdateDeployment(ctx context.Context, deployment *appsv1.Deployment, todoApp *todoappv1.TodoApp) error {
	found := &appsv1.Deployment{}
	err := r.Get(ctx, client.ObjectKey{Name: deployment.Name, Namespace: deployment.Namespace}, found)
	if err != nil && errors.IsNotFound(err) {
		return r.Create(ctx, deployment)
	} else if err != nil {
		return err
	}

	found.Spec = deployment.Spec
	return r.Update(ctx, found)
}

// createOrUpdateService creates or updates the Service
func (r *TodoAppReconciler) createOrUpdateService(ctx context.Context, service *corev1.Service, todoApp *todoappv1.TodoApp) error {
	found := &corev1.Service{}
	err := r.Get(ctx, client.ObjectKey{Name: service.Name, Namespace: service.Namespace}, found)
	if err != nil && errors.IsNotFound(err) {
		return r.Create(ctx, service)
	} else if err != nil {
		return err
	}

	found.Spec.Selector = service.Spec.Selector
	found.Spec.Ports = service.Spec.Ports
	return r.Update(ctx, found)
}

// updateStatus updates the TodoApp status
func (r *TodoAppReconciler) updateStatus(ctx context.Context, todoApp *todoappv1.TodoApp) error {
	// Get the deployment to check status
	deployment := &appsv1.Deployment{}
	err := r.Get(ctx, client.ObjectKey{Name: todoApp.Name, Namespace: todoApp.Namespace}, deployment)
	if err != nil {
		return err
	}

	todoApp.Status.ReadyReplicas = deployment.Status.ReadyReplicas

	// Set conditions
	condition := metav1.Condition{
		Type:    "Ready",
		Status:  metav1.ConditionFalse,
		Reason:  "NotReady",
		Message: fmt.Sprintf("Ready replicas: %d/%d", deployment.Status.ReadyReplicas, *todoApp.Spec.Replicas),
	}

	if deployment.Status.ReadyReplicas == *todoApp.Spec.Replicas {
		condition.Status = metav1.ConditionTrue
		condition.Reason = "Ready"
		condition.Message = "All replicas are ready"
	}

	// Update or add condition
	todoApp.Status.Conditions = []metav1.Condition{condition}

	return r.Status().Update(ctx, todoApp)
}

// SetupWithManager sets up the controller with the Manager.
func (r *TodoAppReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&todoappv1.TodoApp{}).
		Owns(&appsv1.Deployment{}).
		Owns(&corev1.Service{}).
		Named("todoapp").
		Complete(r)
}
