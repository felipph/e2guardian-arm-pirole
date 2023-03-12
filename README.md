## Setup do container do e2guardian

```bash 
sudo apt update
sudo apt install e2guardian vim
```

## construir a imagem ARM no pc
```bash
docker build . --tag felipph/e2guardian --platform arm64
```