IMAGE_PREFIX=volcanosh/vk
TAG=latest

.EXPORT_ALL_VARIABLES:

install-chart:
	./hack/run-e2e-kind.sh

