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