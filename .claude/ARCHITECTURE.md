# Arquitetura

## Princípios

- MVC
- Service Objects
- Query Objects
- Policy Objects
- View Components
- PORO
- SOLID

## Estrutura

Controllers

↓

Services

↓

Repositories

↓

Models

↓

Database

## Nunca

- Controllers com regra de negócio
- Models gordos
- Helpers enormes
- Callbacks complexos

## Sempre

Services pequenos.

Classes coesas.

Baixo acoplamento.

Alta legibilidade.