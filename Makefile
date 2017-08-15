.RECIPEPREFIX = >
.PHONY: deploy

HELM_NAMESPACE=frontend

deploy:
> cd k8s ; \
> helm upgrade --namespace ${HELM_NAMESPACE} --values ./extravals.yaml \
> elm-panel ./sharecrows-elm

