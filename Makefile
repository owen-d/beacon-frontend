.RECIPEPREFIX = >
.PHONY: deploy

HELM_NAMESPACE=frontend

deploy:
> cd k8s ; \
> helm upgrade --install --namespace ${HELM_NAMESPACE} --values ./extravals.yaml \
> elm-panel ./sharecrows-elm

