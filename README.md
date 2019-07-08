# SOL API

Para que as associações e cooperativas realizem as licitações de aquisição de bens, serviços e obras relativas aos seus projetos, os Governos do Estado da Bahia e do Rio Grande do Norte desenvolveram e disponibilizaram o aplicativo de compras SOL (Solução Online de Licitações).

---

Este repositório contém toda a API necessária para demais aplicações:
- sol-admin-frontend;
- sol-cooperative-frontend;
- sol-supplier-frontend.

## Configuração inicial

O executável `setup` deve realizar todo o trabalho necessário, então apenas rode:

```
  bin/setup
```

Após a configuração inicial da aplicação, devemos rodar a task principal para configuração dos dados (`setup:load`).

**Obs:** Não esqueça de setar na aplicação que irá consultar a API os valores de `uid` e `secret` gerados pelo comando acima.

## Iniciando o servidor

O sistema conta com um Procfile e todos seus processos podem ser iniciados por um gerênciador de processos como o foreman, basta executar:

```
 bundle exec foreman start
```

## Testes

O projeto conta com a gem Guard que permite rodar os testes automaticamente ao editar um teste/arquivo, para isso basta executar:

```
 guard
```
