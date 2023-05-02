# Flux diff Github Action

This Github Action validates all `yaml` files in the repo, and runs `kubeconform` on the output of `kustomize build`.

The idea is to catch any error related to `yaml` and `kustomize` before mergin a PR

# Requirements:

- yq 
- kustomize 
- kubeconform  

# Usage

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