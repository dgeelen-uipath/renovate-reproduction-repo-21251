#!/bin/sh -e
# assuming docker login ghcr.io --username dgeelen-uipath --password-stdin

(
info "Switching to '${0%/*}'"
cd "${0%/*}"

for repository in product-name product-name-component ; do
	docker image ls \
		--all \
		--format '{{json .}}' \
		"ghcr.io/dgeelen-uipath/${repository}" \
	| jq --raw-output '.ID'
done \
| sort \
| uniq \
| while read id; do
	docker image rmi --force "${id}"
done

docker build --rm --tag sample .
sample_id=$(docker images --quiet sample)

push_and_tag() {
	local id=${1} ; shift
	local name=${1} ; shift

	while [ $# -gt 0 ] ; do
		version=${1}
		docker tag "${id}" "ghcr.io/dgeelen-uipath/${name}:${version}"
		docker push "ghcr.io/dgeelen-uipath/${name}:${version}"
		shift
	done
}

push_and_tag "${sample_id}" product-name \
	1.0.0
push_and_tag "${sample_id}" product-name-component-one \
	0.1.2 \
	2.3.4 \
	2.3.4-foo.2 \
	2.3.4-foo.{8..12} \
	2.3.4-foo.42 \
	200.3.4
push_and_tag "${sample_id}" product-name-component-two \
	5.6.7-foo.{1..48} \
	5.5.5-foo.78
)
