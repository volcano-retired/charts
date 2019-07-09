IMAGE_PREFIX=volcanosh/vc
TAG=latest

.EXPORT_ALL_VARIABLES:

install-chart:
	./hack/run-e2e-kind.sh

