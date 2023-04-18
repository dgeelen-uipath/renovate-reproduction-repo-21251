#!/bin/sh -e
# assuming docker login ghcr.io --username dgeelen-uipath --password-stdin

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
id=$(docker images --quiet sample)
echo "id: ${id}"

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

id=7b156c595a0f
push_and_tag "${id}" product-name \
	1.0.0
push_and_tag "${id}" product-name-component-one \
	0.1.2 \
	2.3.4 \
	2.3.4-foo.2 \
	2.3.4-foo.{8..12} \
	2.3.4-foo.42 \
	200.3.4
push_and_tag "${id}" product-name-component-two \
	5.6.7-foo.{1..48}
