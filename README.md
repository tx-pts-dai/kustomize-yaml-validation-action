# Kustomize yaml validation

This Github Action validates all `yaml` files in the repo, and runs `kubeconform` on the output of `kustomize build`.

The idea is to catch any error related to `yaml` and `kustomize` before mergin a PR

# Requirements:

- yq 
- kustomize 
- kubeconform  

# Github Action Usage

## Basic usage:

```yaml
      - uses: tx-pts-dai/kustomize-yaml-validation-action@main
```

## Extended example

In this example uses `alexellis/arkade-get` action to install the necesary dependencies and set the input variable `kubeconform-verbose` to `true`:

```yaml
      - uses: alexellis/setup-arkade@v2
      - uses: alexellis/arkade-get@master
        with:
          kustomize: 4.5.7
          kubeconform: v0.6.1

      - uses: tx-pts-dai/kustomize-yaml-validation-action@main
        with:
          kubeconform-verbose: "true"
```

# Download and run the validation script locally:

To download the validation script and execute it locally:

```
curl https://raw.githubusercontent.com/tx-pts-dai/kustomize-yaml-validation-action/main/validate.sh -o validate.sh && \
chmod +x validate.sh
```
# Examples
1. Look for yaml files in folders: infrastructure/dev, infrastructure/prod and apps/prod 
```
./validate.sh false ./clusters "infrastructure/dev infrastructure/prod apps/prod"
```
2. Look for yaml files in all folders
```
./validate.sh false ./clusters __ALL__
```