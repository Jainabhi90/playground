### Install karmada-metrics-adapter

Now we will enable the `karmada-metrics-adapter` addon on the Karmada control plane and register the custom metrics APIService on both member clusters. Together, these steps bridge metrics from member clusters to the FederatedHPA controller.

RUN `bash ~/installMetricsAdapter.sh`{{exec}}

RUN `bash ~/installCustomMetricsAPI.sh`{{exec}}

Wait a few moments for the adapter pods and APIService registration to settle before proceeding.
