# WireGuard Helm Chart

This is a Helm chart for deploying [WireGuard](https://www.wireguard.com) VPN server to a [Kubernetes](https://kubernetes.io) cluster. It's designed to be as simple as possible, while still providing the full functionality of WireGuard with an ability to configure it via static configuration files. 

The chart, by default, uses the [WireGuard Go](https://github.com/masipcat/wireguard-go-docker) Docker image but can be configured to use any other one.

## Motivation
The motivation for creating this chart was to have a simple way to deploy a WireGuard VPN server to a Kubernetes cluster. There are other charts available, but they are either too overcomplicated and require a separate storage for the WireGuard configuration or are not configurable enough. Most charts also don't allow to specify the custom service annotations which are often required to expose the service to a load balancer of a cloud provider.

## Main features
- Automatic generation of the WireGuard configuration file based on the values.yaml file (check out the available options [here](values.yaml)).
- Restarting the WireGuard server when the configuration changes.
- Ability to specify the custom service annotations to support load balancers of different cloud providers.
- Mocking the health check port via an echo server to support load balancers which require TCP health checks.
- Ability to create the custom network policy from the values.yaml file.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
