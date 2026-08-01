import { Controller } from "@hotwired/stimulus"
import { loadMercadoPago } from "@mercadopago/sdk-js"

const POLL_INTERVAL_MS = 5000

export default class extends Controller {
  static targets = [
    "cardTab", "pixTab", "cardSection", "pixSection", "cardError",
    "pixButton", "pixError", "pixResult", "qrImage", "qrCode", "pixExpiry"
  ]

  static values = {
    publicKey: String,
    amount: Number,
    pixUrl: String,
    cardUrl: String,
    orderStatusUrl: String,
    orderUrl: String
  }

  async connect() {
    await loadMercadoPago()
    this.mp = new window.MercadoPago(this.publicKeyValue, { locale: "pt-BR" })
    this.renderCardBrick()
  }

  disconnect() {
    if (this.pollTimer) clearInterval(this.pollTimer)
  }

  showCard() {
    this.cardTabTarget.toggleAttribute("data-active", true)
    this.pixTabTarget.toggleAttribute("data-active", false)
    this.cardSectionTarget.classList.remove("hidden")
    this.pixSectionTarget.classList.add("hidden")
  }

  showPix() {
    this.pixTabTarget.toggleAttribute("data-active", true)
    this.cardTabTarget.toggleAttribute("data-active", false)
    this.pixSectionTarget.classList.remove("hidden")
    this.cardSectionTarget.classList.add("hidden")
  }

  async renderCardBrick() {
    const bricksBuilder = this.mp.bricks()

    this.cardBrick = await bricksBuilder.create("cardPayment", "payment-brick-card", {
      initialization: { amount: this.amountValue },
      callbacks: {
        onSubmit: (cardFormData) => this.submitCard(cardFormData),
        onError: (error) => this.showCardError(error?.message || "Não foi possível carregar o pagamento com cartão."),
      },
    })
  }

  async submitCard(cardFormData) {
    const response = await fetch(this.cardUrlValue, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrfToken },
      body: JSON.stringify(cardFormData),
    })
    const data = await response.json()

    if (response.ok) {
      window.location.href = data.redirect_url
    } else {
      this.showCardError((data.errors || []).join(", "))
    }
  }

  showCardError(message) {
    this.cardErrorTarget.textContent = message
    this.cardErrorTarget.classList.remove("hidden")
  }

  async generatePix() {
    this.pixButtonTarget.disabled = true
    this.pixErrorTarget.classList.add("hidden")

    const response = await fetch(this.pixUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": this.csrfToken },
    })
    const data = await response.json()

    if (response.ok) {
      this.qrImageTarget.src = `data:image/png;base64,${data.qr_code_base64}`
      this.qrCodeTarget.value = data.qr_code
      this.pixExpiryTarget.textContent = `Expira às ${new Date(data.expires_at).toLocaleTimeString("pt-BR")}`
      this.pixResultTarget.classList.remove("hidden")
      this.pollOrderStatus()
    } else {
      this.pixErrorTarget.textContent = (data.errors || []).join(", ")
      this.pixErrorTarget.classList.remove("hidden")
      this.pixButtonTarget.disabled = false
    }
  }

  pollOrderStatus() {
    this.pollTimer = setInterval(async () => {
      const response = await fetch(this.orderStatusUrlValue, { headers: { Accept: "application/json" } })
      const data = await response.json()

      if (data.status !== "pending") {
        clearInterval(this.pollTimer)
        window.location.href = this.orderUrlValue
      }
    }, POLL_INTERVAL_MS)
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }
}
