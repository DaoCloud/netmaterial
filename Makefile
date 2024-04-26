include ./Makefile.defs

.PHONY: update_dockerfile
update_dockerfile:
	rm -f images/Dockerfile ; \
	touch images/Dockerfile ;\
	echo "# this file is entirly generated by makefile" >> images/Dockerfile ; \
	OS_LIST=`jq -r '.[] | "\(.os)|\(.baseImage)"' ./images/smc-os-list.json`; \
	echo $${OS_LIST} ; \
	for OS in $${OS_LIST} ; do \
		os_name=`echo $${OS} | awk -F '|' '{print $$1}'` ; \
		os_image=`echo $${OS} | awk -F '|' '{print $$2}'` ; \
		printf 'ARG base_image_%s=%s\n' "$${os_name}" "$${os_image}" >> images/Dockerfile ;\
	done ; \
	printf '\n' >> images/Dockerfile ; \
	for OS in $${OS_LIST} ; do \
		os_name=`echo $${OS} | awk -F '|' '{print $$1}'` ; \
		printf 'FROM --platform=$${BUILDPLATFORM} $${base_image_%s} as %s_builder\n' "$${os_name}" "$${os_name}" >> images/Dockerfile ; \
		printf 'ADD install-tools.sh .\nRUN chmod +x install-tools.sh && ./install-tools.sh\n' >> images/Dockerfile ;\
		printf '\n' >> images/Dockerfile ; \
		done ; \
	printf 'FROM alpine:3\n' >> images/Dockerfile ;\
	for OS in $${OS_LIST} ; do \
		os_name=`echo $${OS} | awk -F '|' '{print $$1}'` ; \
		printf 'RUN mkdir -p /host/%s/usr/bin && mkdir -p /host/%s/usr/lib\n' "$${os_name}" "$${os_name}" >> images/Dockerfile ; \
		printf 'COPY --from=%s_builder /host/%s/usr/bin /host/%s/usr/bin\n' "$${os_name}" "$${os_name}" "$${os_name}" >> images/Dockerfile ; \
		printf 'COPY --from=%s_builder /host/%s/usr/lib/libsmc-preload.so /host/%s/usr/lib\n' "$${os_name}" "$${os_name}" "$${os_name}" >> images/Dockerfile ; \
		printf '\n' >> images/Dockerfile ; \
	done ;\
	printf 'WORKDIR /host/\n'  >> images/Dockerfile ; \
	printf 'ADD modules /host/modules\n' >> images/Dockerfile ; \
	printf 'ADD entrypoint.sh /host/\n'  >> images/Dockerfile ;\
	printf 'ADD smc-os-list.json /host/\n'  >> images/Dockerfile ;\
	printf 'RUN chmod +x /host/entrypoint.sh\n' >> images/Dockerfile ;\
	printf '\n' >> images/Dockerfile; \
	printf 'ENTRYPOINT ["sh","entrypoint.sh"]\n' >> images/Dockerfile 
 
 .PHONY: build_image
 build_image: update_dockerfile
	$(CONTAINER_RUNTIME) buildx build --build-arg GIT_COMMIT_VERSION=$(GIT_COMMIT_VERSION) \
		--build-arg GIT_COMMIT_TIME=$(GIT_COMMIT_TIME) \
		--build-arg VERSION=$(GIT_COMMIT_VERSION) \
		--file images/Dockerfile \
		--output type=docker --tag $(IMAGE_REGISTER)/$(GIT_REPO):$(GIT_TAG) images