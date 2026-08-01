# Current Phase

Versão Atual

MVP

Sprint

Sprint 02

Objetivo

Colocar a loja no ar para o cliente final: vitrine pública, carrinho, pedidos, checkout e pagamento via Mercado Pago.

Status

Backend da Sprint 02 concluído. Loja ainda não foi para o ar — falta identidade visual real (ver Próxima Feature) e deploy (ver ROADMAP/futura Sprint 03).

Sprints concluídas

Sprint 01 — Setup Rails, Devise, ActiveAdmin, Produtos (cadastro de Produtos, Categorias, Estoque simples e Upload de Imagens — painel manual em /admin, ver DECISIONS.md).

Funcionalidades da Sprint (ordem obrigatória, por dependência)

1. Landing Page (vitrine pública) — concluída. "Tema único" ficou só estruturalmente pronto (Tailwind minimalista genérico, sem identidade visual própria) — ver Próxima Feature.
2. Carrinho — concluída
3. Pedidos — concluída
4. Checkout — concluída
5. Mercado Pago — concluída (PIX + Cartão de crédito, Checkout Transparente/Bricks; ver DECISIONS.md)

Bug crítico encontrado e corrigido nesta sprint (fora do escopo de feature, mas bloqueava tudo): `yarn build:css` nunca funcionou neste ambiente (Yarn PnP incompatível com o resolver de módulos do Tailwind v4) — a loja estava rodando sem nenhum CSS compilado desde o Sprint 01. Corrigido com `.yarnrc.yml` (`nodeLinker: node-modules`); ver DECISIONS.md.

Próxima Feature

Tema Único (identidade visual real do storefront: cores de marca, tipografia, logo, seção hero da home etc. — não apenas o Tailwind genérico atual). Em Discovery/brainstorming, a continuar em uma nova sessão (usuário pediu explicitamente para retomar em sessão nova, com o companion visual).

Nunca desenvolver funcionalidades que não estejam nesta Sprint.