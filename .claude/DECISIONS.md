## 2026-08-01

Decisão

Não utilizar Spree.

Motivo

Complexidade elevada.

---

## 2026-08-03

Decisão

Mercado Pago será o único gateway do MVP.

Motivo

Simplificar desenvolvimento.

---

## 2026-08-10

Decisão

React será utilizado apenas no Builder.

Motivo

Reduzir complexidade.

---

## 2026-08-01

Decisão

Autenticação administrativa usa model `AdminUser` dedicado (não `User` genérico), com módulos Devise `database_authenticatable, recoverable, rememberable, validatable, trackable, lockable`. Sem `registerable`: admins não se autocadastram, contas criadas via seed/console.

Motivo

Admin e Cliente são identidades com regras diferentes (BUSINESS_RULES.md). Separar os models evita acoplamento entre painel administrativo e área do cliente, que terá seu próprio fluxo de autenticação (com self-signup) no futuro.

---

## 2026-08-01

Decisão

UUID como primary key passa a ser o default de todos os generators (`config.generators { |g| g.orm :active_record, primary_key_type: :uuid }` em `config/application.rb`), configurado junto com o primeiro model (`AdminUser`).

Motivo

DATABASE_GUIDELINES.md exige UUID em todas as tabelas; configurar o default agora evita ter que lembrar de passar `id: :uuid` manualmente em cada migration futura.

---

## 2026-08-01

Decisão

ActiveAdmin autentica usando o model `AdminUser`/Devise já existente (`rails g active_admin:install AdminUser --skip-users`), em vez de deixar o generator criar seu próprio model de usuário. Montado em `/admin_panel` (`config.default_namespace = :admin_panel`), não em `/admin`, para não colidir com o dashboard administrativo manual (`Admin::DashboardController`) que já existia em `/admin/dashboard` e foi mantido. `config.comments = false` esconde o item de menu de comentários, mas o ActiveAdmin registra as rotas/controller de `Comments` incondicionalmente (independem desse flag) — por isso a migration `active_admin_comments` foi mantida (não removida), ajustada para `id: :uuid` e FKs polimórficas (`resource`, `author`) tipadas como `:uuid`, compatíveis com `AdminUser`. Polymorphic aqui é justificado: é a própria natureza do recurso de comentários do ActiveAdmin, que precisa referenciar qualquer resource registrado.

Motivo

Evitar dois models de admin distintos (AdminUser duplicado) e reaproveitar a autenticação já validada. O dashboard manual não pertencia a esta feature, então não foi removido — ActiveAdmin passou a ocupar um path próprio ao invés de substituí-lo. A primeira tentativa desta decisão removeu a migration de comments, mas isso deixava `/admin_panel/comments` acessível e quebrado (tabela inexistente); corrigido mantendo a tabela em conformidade com DATABASE_GUIDELINES.md.

---

## 2026-08-01

Decisão

Adicionada a gem `dartsass-rails`, restrita a compilar apenas `app/assets/stylesheets/active_admin.scss` (`config/initializers/dartsass.rb` sobrescreve `config.dartsass.builds`). O pipeline de CSS da loja continua 100% Tailwind CLI via `cssbundling-rails`, sem alteração.

Motivo

O projeto usa Propshaft (sem Sprockets/Sass nativo), mas os assets padrão do ActiveAdmin são SCSS com mixins/partials. `dartsass-rails` não tem dependência nativa e é compatível com Propshaft, então foi isolado apenas para o ActiveAdmin em vez de reintroduzir Sass no pipeline principal da aplicação.

---

## 2026-08-01

Decisão

Feature Produtos implementada com painel manual em `/admin` (`Admin::ProductsController`/`Admin::CategoriesController`, Controllers → Services → Query Objects → Models), e não via ActiveAdmin. Gems `pundit` (~> 2.5) e `view_component` (~> 4.12), já previstas em TECH_STACK.md, foram adicionadas ao Gemfile nesta feature (primeiro uso real). `Admin::BaseController` foi extraído para compartilhar `authenticate_admin_user!` entre `DashboardController`, `ProductsController`, `CategoriesController` e `ProductImagesController`.

Motivo

Escolha explícita do usuário no Discovery: o painel manual já nasce seguindo a arquitetura completa do projeto (Service Objects/Policies/ViewComponents), evitando reescrever depois o que o ActiveAdmin faria de forma genérica. ActiveAdmin em `/admin_panel` continua disponível como painel administrativo genérico, sem relação com o CRUD de Produtos.

---

## 2026-08-01

Decisão

Modelagem de Produtos: `Category` sem hierarquia (sem `parent_id`); `Product.stock_quantity` como campo simples no próprio model (sem model `Stock` separado); `Product` sem campo de preço promocional (apenas `price`); imagens via `has_many_attached :images` (ActiveStorage) sem gem `image_processing` — miniaturas são exibidas via `image_tag` com classes CSS de tamanho fixo, sem `.variant` (resize no servidor). Concern `Sluggable` (`app/models/concerns/sluggable.rb`) compartilha a geração de slug entre `Category` e `Product`. `price` e `stock_quantity` têm CHECK constraints no banco (`price > 0`, `stock_quantity >= 0`) além das validações de model.

Motivo

Escolhas explícitas do usuário no Discovery para manter o escopo do MVP enxuto: hierarquia de categorias, histórico de movimentação de estoque, preço promocional e redimensionamento de imagem no servidor não são necessários agora e foram adiados para quando houver necessidade real (loja pública, promoções, catálogo com variação de SKU). Regra de negócio "produto sem estoque não pode ser vendido" e "produto inativo nunca aparece na loja" (BUSINESS_RULES.md) ainda não têm efeito prático porque a loja pública é feature futura; os scopes `Product.active`/`Product.in_stock` já existem para serem reaproveitados quando ela for implementada.

---

## 2026-08-01

Decisão

Sprint 02 definida (ver CURRENT_PHASE.md): Landing Page → Carrinho → Pedidos → Checkout → Mercado Pago, nessa ordem. Primeira feature implementada: Landing Page (vitrine pública em `/`, `/produtos/:slug`, `/categorias/:slug`), sob `Storefront::{Home,Products,Categories}Controller` + `Storefront::BaseController`, layout próprio `layouts/storefront.html.erb` (não reaproveita o layout/visual do `/admin`). `Product.active`/`Category.active` (já existentes) passam a ter efeito prático real: só categorias/produtos ativos aparecem na loja; produto com `stock_quantity` zerado aparece na listagem marcado "Indisponível" (`Storefront::AvailabilityBadgeComponent`) em vez de ser ocultado. Sem Policy Objects (Pundit) nesta feature: é conteúdo público sem ator/papel envolvido, e a visibilidade já é resolvida pelos scopes de model — criar policies aqui seria burocracia sem checagem real de permissão.

Motivo

Ordem da Sprint 02 segue a dependência real entre as features (não dá pra ter Carrinho sem o cliente conseguir ver produtos primeiro). Layout separado porque `/admin` é painel interno, com identidade visual e propósito diferentes da loja voltada ao cliente final. Mostrar produto sem estoque (em vez de escondê-lo) foi decisão do usuário no Discovery, priorizando catálogo/SEO; o bloqueio de compra em si fica para a feature Carrinho.

---

## 2026-08-01

Decisão

Gem de paginação fixada em `pagy ~> 9.4` (API clássica `Pagy::Backend#pagy` / `Pagy::Frontend#pagy_nav`), não na última publicada (`43.x`).

Motivo

A partir da versão `43.0.0` a gem passou por uma reescrita completa de API (paginadores `Pagy::Method`/`Pagy::Offset`, sem `Pagy::Backend`/`Pagy::Frontend`/`pagy_nav` clássicos), sem CHANGELOG/documentação embarcada no gem para confirmar o uso correto. Implementar contra uma API desconhecida e mal documentada localmente é risco desnecessário para o MVP; `9.4.0` é a última da linha clássica, estável e amplamente documentada.

---

## 2026-08-01

Decisão

Feature Carrinho implementada sem model de Cliente/autenticação de loja (nenhum existe no MVP — ver ROADMAP.md). O carrinho é identificado por um cookie assinado permanente (`cookies.signed.permanent[:purchase_token]`), gerado no primeiro `POST` de adicionar item; visualizar `/carrinho` sem nunca ter adicionado algo não cria registro em banco. Modelagem: `Purchase` (`id uuid`, `token uuid unique`) e `PurchaseItem` (`purchase_id`, `product_id`, `quantity`, unique `[purchase_id, product_id]`, CHECK `quantity > 0`) — nomeados `Purchase`/`PurchaseItem` (não `Cart`/`CartItem`) por escolha explícita do usuário. `PurchaseItem` não congela o preço do produto: `subtotal` é calculado a partir do `Product.price` vigente no momento da renderização; o congelamento de preço fica a cargo do Pedido (feature seguinte da Sprint 02). Sem Policy Object (Pundit): mesmo racional da Landing Page — sem ator/papel, o próprio escopo `current_purchase.purchase_items.find(...)` já restringe cada carrinho ao dono do cookie. Regras de estoque (`Product.active`/quantidade disponível) aplicadas em `Purchases::AddItemService`/`Purchases::UpdateItemQuantityService`, retornando o registro com `errors` preenchido em vez de lançar exceção (mesmo padrão de `Products::CreateService`/`UpdateService`).

Motivo

Roadmap do MVP não inclui cadastro de Cliente — checkout guest é a única opção viável nesta sprint, e cookie assinado permanente preserva o carrinho entre visitas sem exigir login (Shopify-like), ao contrário de guardar só em `session`. Persistir em banco (não só cookie/sessão) prepara a conversão do carrinho em Pedido na próxima feature. O nome `Purchase`/`PurchaseItem` foi decisão explícita do usuário durante a implementação, substituindo a nomenclatura `Cart`/`CartItem` original do Discovery — atenção ao risco de colisão semântica com o futuro model de Pedido, a esclarecer se necessário quando essa feature for implementada.

---

## 2026-08-01

Decisão

Feature Pedidos implementada reaproveitando `Purchase`/`PurchaseItem` (sem novo model `Order`), resolvendo o risco de colisão semântica sinalizado na decisão do Carrinho: `Purchase` ganhou `status` (enum `cart: 0, pending: 1, paid: 2, cancelled: 3, expired: 4`, default `cart`) e passa a representar tanto o carrinho ativo quanto o pedido. Scope `Purchase.placed` (`where.not(status: :cart)`) é o que o `/admin` considera "Pedido" de fato. `PurchaseItem` ganhou `unit_price` (nullable) — enquanto `cart`, `subtotal` usa `Product.price` ao vivo; a partir de `pending`, usa o `unit_price` congelado. Campos `customer_name`/`customer_email`/`customer_phone` (nullable) e `expires_at` (para o PIX) foram adicionados ao schema nesta feature mas ainda não têm formulário que os preencha — isso é responsabilidade da feature Checkout (próxima da Sprint). `Orders::PlaceService` faz a transição `cart → pending`: valida estoque disponível, congela `unit_price` e **reduz o estoque do produto no momento em que o pedido é colocado** (reserva), não apenas quando pago. `Orders::CancelService` faz `pending|paid → cancelled`, sempre devolvendo o estoque. Painel `/admin/orders` (`Admin::OrdersController` + `PurchasePolicy`) permite listar, ver detalhe e cancelar pedidos (regra "Administrador pode cancelar pedidos"); sem tela pública de consulta de pedido.

Motivo

Reservar estoque em `pending` (e não apenas em `paid`) foi decisão explícita do usuário no Discovery desta feature: como `paid` só é alcançável na próxima feature (Mercado Pago), reduzir estoque somente no pagamento deixaria dois pedidos `pending` concorrentes reservarem a mesma última unidade — risco real de overselling. Isso diverge do texto literal do BUSINESS_RULES.md ("Pedido pago reduz estoque"), que deveria ser ajustado para refletir que a redução ocorre na colocação do pedido, e não na confirmação do pagamento (a confirmação apenas mantém o estoque já reservado, sem reduzir de novo). Reaproveitar `Purchase` (em vez de criar `Order`) foi decisão explícita do usuário, mesma linha da modelagem do Carrinho. Dados do comprador e expiração do PIX entraram no schema agora para evitar uma segunda migration na feature Checkout, mas seu preenchimento é explicitamente fora de escopo desta feature.

Pendência conhecida (não corrigida nesta feature, por estar fora do escopo combinado): `Storefront::BaseController#current_purchase`/`Purchases::FindOrCreateService` buscam o carrinho apenas por `token`, sem filtrar `status: :cart` — se o mesmo cookie for reaproveitado após um pedido já ter sido colocado, o cliente cairia no pedido antigo em vez de um carrinho novo. A feature Checkout precisa tratar isso (filtrar por `status: :cart` e criar uma nova `Purchase` quando a atual já tiver sido colocada).

---

## 2026-08-01

Decisão

Feature Checkout implementada. Endereço de entrega em model próprio `Address` (`belongs_to :purchase`, FK única — 1:1), e não em colunas soltas no `Purchase`: evita colunas quase sempre nulas na tabela principal, já que endereço só existe a partir do momento em que o carrinho vira pedido. `Checkout::Form` (Form Object, `ActiveModel::Model`, `app/services/checkout/form.rb` — sem diretório `forms/` próprio, pois FOLDER_STRUCTURE.md não define um) valida `customer_name`/`customer_email`/`customer_phone` + campos do `Address` (obrigatórios só no momento do checkout, não no model `Purchase`/`Address` fora desse fluxo) e, em uma única transação, grava os dados do cliente, cria o `Address` e delega a `Orders::PlaceService` (já existente, feature Pedidos) para a transição `cart → pending`; se `PlaceService` falhar (ex.: estoque insuficiente), a transação inteira é revertida (`ActiveRecord::Rollback`) e os erros dos `purchase_items`/`purchase` são copiados para `Form#errors`, mantendo `Purchase`/`Address` limpos. `Storefront::CheckoutsController` (`new`/`create`, rotas `/finalizar-pedido`) e `Storefront::OrdersController` (`show`, rota pública `/pedidos/:id` via UUID, `Purchase.placed.find`) — sem Policy Object, mesma justificativa da Landing Page/Carrinho (sem ator/papel). Corrigido nesta feature o bug conhecido: `Storefront::BaseController#current_purchase` e `Purchases::FindOrCreateService` agora filtram por `Purchase.cart` antes de buscar pelo `token` do cookie, então depois de um pedido colocado o próximo item adicionado ao carrinho cria uma `Purchase` nova (token novo) em vez de reaproveitar o pedido já finalizado.

Motivo

Endereço em tabela própria e Form Object com validações específicas do checkout foram decisões explícitas do usuário/arquitetura no Discovery, para não sujar `Purchase`/`Address` com regras de obrigatoriedade que só valem nesse fluxo. Rollback da transação inteira (em vez de persistir parcialmente cliente/endereço mesmo com o pedido falhando) evita um `Purchase` com dados de checkout preenchidos mas ainda em `cart`, o que confundiria o próximo carrinho do mesmo cookie. Fluxo validado manualmente via HTTP (curl) contra o servidor de desenvolvimento: adicionar item → checkout → confirmação → estoque reduzido → carrinho seguinte já nasce vazio com token novo.

---

## 2026-08-01

Decisão

Feature Mercado Pago implementada: PIX + Cartão de crédito (parcelado, com juros do próprio Mercado Pago), via Checkout Transparente (Bricks), sem redirecionar o cliente para fora da loja. Novo model `Payment` (`belongs_to :purchase`, `has_many :payments` em `Purchase` — não `has_one`, pois cartão recusado permite nova tentativa sem descartar a anterior) guarda `mp_payment_id` (unique), `payment_method` (enum `pix`/`credit_card` — não `method`, que colide com `Kernel#method`), `status` (enum `pending/approved/rejected/cancelled/refunded`, mapeado do `status` retornado pela API via `Payments::StatusMapper`), `amount`, `installments`, `status_detail`, `qr_code`/`qr_code_base64` (PIX). Nenhum payload bruto da API é persistido (JSON quebraria DATABASE_GUIDELINES.md) — só os campos que o domínio usa. Fluxo: `Storefront::CheckoutsController#create` agora redireciona para `/pedidos/:id/pagamento` (não mais direto para `/pedidos/:id`); essa página (Stimulus + `@mercadopago/sdk-js`, sem React — DECISIONS.md de 2026-08-10) renderiza o Card Payment Brick e um botão de PIX, que chamam `Storefront::Payments::{Pix,CreditCards}Controller#create` (JSON) via fetch. `Payments::CreatePixService`/`CreateCreditCardService` chamam a API do Mercado Pago (`lib/mercado_pago/client.rb`, wrapper fino sobre o SDK oficial) e retornam sempre um `Payment` (persistido ou com `errors`, mesmo padrão de `Orders::PlaceService`). Cartão aprovado confirma o pedido na hora (`Orders::ConfirmPaymentService`, síncrono); PIX fica `pending` até o webhook. Webhook público `POST /webhooks/mercado_pago` (`Webhooks::MercadoPagoController < ActionController::Base`, não `ApplicationController`, para não herdar `allow_browser versions: :modern` nem `Pundit::Authorization` — é a Mercado Pago chamando, não um navegador) valida a assinatura (`Mercadopago::Webhook::Validator`, HMAC) antes de processar, e nunca confia no `status` do corpo da notificação: sempre busca de novo o pagamento na API (`Payments::Webhooks::HandleNotificationService`) antes de confirmar o pedido — mitiga notificação forjada (SECURITY.md, "nunca confiar em parâmetros"). Expiração do PIX (30min, BUSINESS_RULES.md) via `Payments::ExpirePixJob` (Sidekiq, `perform_later` com `wait: 30.minutes`) chamando `Orders::ExpireService` (novo, mirror de `CancelService` mas para o status `expired` já existente desde a feature Pedidos); o job é idempotente/seguro contra corrida porque `ExpireService` só age se o pedido ainda estiver `pending` — se o pagamento aprovar antes dos 30 minutos, o pedido já virou `paid` e o job não faz nada.

Bug encontrado e corrigido na gem oficial (`mercadopago-sdk` 3.2.1): o autorequire do Bundler para o gem `mercadopago-sdk` resolve para `lib/mercadopago/sdk.rb` diretamente (por causa do nome do gem coincidir com esse caminho), pulando `lib/mercadopago.rb`, que é o arquivo que de fato carrega `Payment`, `Config`, `RequestOptions` e todos os outros recursos — sem isso, `Mercadopago::SDK.new(token).payment` quebra em produção com `NameError`. Corrigido fixando `require: "mercadopago"` no Gemfile. Além disso, `Mercadopago::Webhook::Validator` nem é requerido por `lib/mercadopago.rb` — precisou de `require "mercadopago/webhook/validator"` explícito em `config/initializers/mercado_pago.rb`.

Motivo

PIX + Cartão parcelado (com juros do Mercado Pago, não da loja) e Checkout Transparente foram escolhas explícitas do usuário no Discovery desta feature — a última para manter a experiência de pagamento dentro do visual/UX da loja, já construído no Checkout, em vez de redirecionar para o Checkout Pro do Mercado Pago. `has_many :payments` (não `has_one`) é necessário porque cartão recusado precisa permitir nova tentativa (novo `Payment`) sem apagar o histórico da tentativa anterior. Buscar o pagamento de novo na API em vez de confiar no webhook é inegociável em termos de segurança: qualquer requisição forjada para o endpoint público poderia confirmar pedidos não pagos.

---

## 2026-08-01

Decisão

TECH_STACK.md previa Sidekiq + Redis para jobs, mas o setup inicial (Sprint 01) configurou Solid Queue (default do Rails 8: `config.active_job.queue_adapter = :solid_queue` em produção, gem `solid_queue`), sem que isso tivesse sido registrado como decisão. Esse conflito foi identificado e explicitado ao usuário no Discovery da feature Mercado Pago (necessidade de job agendado para expirar o PIX em 30min), que optou por seguir TECH_STACK.md ao pé da letra: gem `sidekiq` adicionada, `config.active_job.queue_adapter = :sidekiq` em produção e desenvolvimento (para o job de expiração do PIX se comportar igual em ambos — Solid Queue's `:async` de desenvolvimento não sobrevive a um restart do servidor, o que mascararia bugs de agendamento), worker `bundle exec sidekiq -C config/sidekiq.yml` adicionado ao `Procfile.dev`. Ambiente de teste não foi alterado (mantém o adapter `:test` padrão do Rails, sem depender de Redis para rodar a suíte). A infraestrutura do Solid Queue (gem, banco `queue` em `database.yml`, `bin/jobs`, `config/recurring.yml`) foi deixada como está — nenhum job a usa mais, mas removê-la (incluindo o banco de produção já provisionado) é uma mudança de infra maior e fora do escopo combinado nesta sessão; pode ser limpa depois se nenhuma feature futura vier a precisar dela.

Motivo

Seguir TECH_STACK.md ao invés de manter Solid Queue evita o app ter dois backends de job "oficiais" implicitamente divergentes entre a documentação e o código; a alternativa (registrar Solid Queue como a decisão real e atualizar TECH_STACK.md) foi oferecida e recusada pelo usuário. Redis como accessory de deploy (Kamal) ainda não foi configurado — DEPLOY.md está vazio, então fica como pendência para quando a etapa de deploy desta feature for tratada.

---

## 2026-08-01

Decisão

Bug crítico corrigido: `yarn build:css` (`npx @tailwindcss/cli ...`) nunca gerava `app/assets/builds/application.css` neste ambiente — falhava com `Error: Some options passed to require() aren't supported by PnP yet (conditions)`. Causa: Yarn está em modo PnP (`nodeLinker: pnp`, default do Yarn Berry, sem `.yarnrc.yml` no projeto até então) e `@tailwindcss/node` 4.3.3 usa uma API nova do Node (`require(id, { conditions })`) que o shim de `require` do PnP não suporta — reproduzido tanto via `npx` quanto via `yarn tailwindcss` (não é um problema de `npx` especificamente, é PnP vs. `@tailwindcss/node`). Como `app/assets/builds/application.css` nunca existia, o Propshaft caía para servir `app/assets/stylesheets/application.tailwind.css` (o arquivo fonte, não processado — 23 bytes, só `@import "tailwindcss";`) sempre que `stylesheet_link_tag :app`/`"application"` era chamado. Resultado: a loja pública e o painel `/admin` rodavam sem nenhuma classe Tailwind aplicada desde o Sprint 01, sem que ninguém tivesse notado (nenhuma sessão anterior tinha aberto a aplicação num navegador para conferir visualmente). Corrigido adicionando `.yarnrc.yml` com `nodeLinker: node-modules` (`node_modules/` já estava no `.gitignore`) — isso troca a resolução de módulos do Yarn para o layout clássico, que `@tailwindcss/node` suporta. Aproveitado para trocar `layouts/storefront.html.erb` de `stylesheet_link_tag :app` (que no Propshaft inclui *todo* CSS do projeto — nesse caso também carregava `active_admin.css`, 60KB, na loja pública) para `stylesheet_link_tag "application"`, que resolve só o CSS correto da loja. `layouts/application.html.erb` (painel `/admin` manual) manteve `:app` — é o layout default do Rails, sem essa preocupação de escopo.

Motivo

Encontrado ao investigar o relato do usuário de que a loja estava "sem layout nenhum" antes de iniciar o Discovery da feature Tema Único — precisava descartar bug de build antes de discutir design visual de verdade. Corrigir o `nodeLinker` no `.yarnrc.yml` do projeto (em vez de, por exemplo, trocar de versão do Tailwind ou do Node) foi a correção mais direta e de menor risco: não muda nenhuma dependência de versão, só a forma como o Yarn resolve módulos localmente.