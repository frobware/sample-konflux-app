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

package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.

// TodoAppSpec defines the desired state of TodoApp.
type TodoAppSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	// Image specifies the container image for the TodoApp
	Image string `json:"image,omitempty"`

	// Replicas specifies the number of replicas for the TodoApp deployment
	Replicas *int32 `json:"replicas,omitempty"`

	// Port specifies the port the TodoApp listens on
	Port int32 `json:"port,omitempty"`
}

// TodoAppStatus defines the observed state of TodoApp.
type TodoAppStatus struct {
	// INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	// ReadyReplicas indicates the number of ready replicas
	ReadyReplicas int32 `json:"readyReplicas,omitempty"`

	// Conditions represent the current conditions of the TodoApp
	Conditions []metav1.Condition `json:"conditions,omitempty"`
}

// +kubebuilder:object:root=true
// +kubebuilder:subresource:status

// TodoApp is the Schema for the todoapps API.
type TodoApp struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   TodoAppSpec   `json:"spec,omitempty"`
	Status TodoAppStatus `json:"status,omitempty"`
}

// +kubebuilder:object:root=true

// TodoAppList contains a list of TodoApp.
type TodoAppList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []TodoApp `json:"items"`
}

func init() {
	SchemeBuilder.Register(&TodoApp{}, &TodoAppList{})
}
