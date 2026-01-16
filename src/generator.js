const DEFAULT_BRAND = {
  name: "MinhaMarca",
  primaryColor: "#4F46E5",
  secondaryColor: "#111827",
  backgroundColor: "#F9FAFB",
  textColor: "#111827",
  footerText: "Você recebeu este e-mail porque se cadastrou em nossa lista.",
};

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function renderButton(cta, color) {
  if (!cta || !cta.text || !cta.url) {
    return "";
  }

  return `
    <a href="${escapeHtml(cta.url)}" style="display:inline-block;background:${color};color:#fff;padding:12px 20px;border-radius:6px;text-decoration:none;font-weight:600;">
      ${escapeHtml(cta.text)}
    </a>
  `;
}

function renderHeader({ brand, subject, preheader }) {
  const brandName = escapeHtml(brand.name || DEFAULT_BRAND.name);
  const preheaderText = preheader ? escapeHtml(preheader) : "";

  return `
    <div style="display:none;max-height:0;overflow:hidden;color:#f3f4f6;">
      ${preheaderText}
    </div>
    <table width="100%" cellpadding="0" cellspacing="0" style="background:${brand.backgroundColor};padding:24px 0;font-family:Arial,sans-serif;">
      <tr>
        <td align="center">
          <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 8px 20px rgba(15,23,42,0.08);">
            <tr>
              <td style="padding:24px;background:${brand.primaryColor};color:#fff;">
                <div style="font-size:20px;font-weight:700;">${brandName}</div>
                <div style="font-size:14px;opacity:0.9;">${escapeHtml(subject || "")}</div>
              </td>
            </tr>
            <tr>
              <td style="padding:32px;">
  `;
}

function renderFooter({ brand }) {
  return `
              </td>
            </tr>
            <tr>
              <td style="padding:20px 32px;background:${brand.backgroundColor};color:${brand.secondaryColor};font-size:12px;line-height:1.6;">
                ${escapeHtml(brand.footerText || DEFAULT_BRAND.footerText)}
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  `;
}

function renderNewsletter(payload) {
  const hero = payload.hero || {};
  const sections = Array.isArray(payload.sections) ? payload.sections : [];

  const sectionHtml = sections
    .map((section) => {
      const items = Array.isArray(section.items) ? section.items : [];
      const itemsHtml = items
        .map(
          (item) => `
            <li style="margin-bottom:8px;">${escapeHtml(item)}</li>
          `,
        )
        .join("");

      return `
        <div style="margin-bottom:24px;">
          <h2 style="margin:0 0 8px;font-size:18px;color:${payload.brand.secondaryColor};">${escapeHtml(
            section.title || "",
          )}</h2>
          <p style="margin:0 0 12px;color:${payload.brand.textColor};line-height:1.6;">${escapeHtml(
            section.body || "",
          )}</p>
          ${items.length ? `<ul style="padding-left:18px;">${itemsHtml}</ul>` : ""}
        </div>
      `;
    })
    .join("");

  return `
    <h1 style="margin:0 0 12px;font-size:24px;color:${payload.brand.secondaryColor};">${escapeHtml(
      hero.title || "",
    )}</h1>
    <p style="margin:0 0 20px;color:${payload.brand.textColor};line-height:1.6;">${escapeHtml(
      hero.subtitle || "",
    )}</p>
    ${renderButton(hero.cta, payload.brand.primaryColor)}
    <hr style="border:none;border-top:1px solid #E5E7EB;margin:24px 0;" />
    ${sectionHtml}
  `;
}

function renderPromocao(payload) {
  const offer = payload.offer || {};
  const highlights = Array.isArray(offer.highlights) ? offer.highlights : [];

  return `
    <h1 style="margin:0 0 12px;font-size:26px;color:${payload.brand.secondaryColor};">${escapeHtml(
      offer.title || "",
    )}</h1>
    <p style="margin:0 0 18px;color:${payload.brand.textColor};line-height:1.6;">${escapeHtml(
      offer.description || "",
    )}</p>
    <div style="background:${payload.brand.backgroundColor};padding:16px;border-radius:10px;margin-bottom:20px;">
      <div style="font-size:32px;font-weight:700;color:${payload.brand.primaryColor};">${escapeHtml(
        offer.discountLabel || "",
      )}</div>
      <div style="color:${payload.brand.textColor};">${escapeHtml(offer.validUntil || "")}</div>
    </div>
    <ul style="padding-left:18px;margin:0 0 20px;">
      ${highlights.map((item) => `<li style="margin-bottom:8px;">${escapeHtml(item)}</li>`).join("")}
    </ul>
    ${renderButton(offer.cta, payload.brand.primaryColor)}
  `;
}

function renderCarrinhoAbandonado(payload) {
  const cart = payload.cart || {};
  const items = Array.isArray(cart.items) ? cart.items : [];

  const itemsHtml = items
    .map(
      (item) => `
        <tr>
          <td style="padding:10px 0;border-bottom:1px solid #E5E7EB;">${escapeHtml(item.name)}</td>
          <td align="right" style="padding:10px 0;border-bottom:1px solid #E5E7EB;">${escapeHtml(
            item.price,
          )}</td>
        </tr>
      `,
    )
    .join("");

  return `
    <h1 style="margin:0 0 12px;font-size:24px;color:${payload.brand.secondaryColor};">${escapeHtml(
      cart.title || "",
    )}</h1>
    <p style="margin:0 0 18px;color:${payload.brand.textColor};line-height:1.6;">${escapeHtml(
      cart.description || "",
    )}</p>
    <table width="100%" cellpadding="0" cellspacing="0" style="font-size:14px;margin-bottom:16px;">
      ${itemsHtml}
      <tr>
        <td style="padding:12px 0;font-weight:700;">Total</td>
        <td align="right" style="padding:12px 0;font-weight:700;">${escapeHtml(cart.total || "")}</td>
      </tr>
    </table>
    ${renderButton(cart.cta, payload.brand.primaryColor)}
  `;
}

function generateEmailHtml(payload) {
  const brand = { ...DEFAULT_BRAND, ...(payload.brand || {}) };
  const normalized = {
    ...payload,
    brand,
  };

  let content;
  switch (payload.layout) {
    case "newsletter":
      content = renderNewsletter(normalized);
      break;
    case "promocao":
      content = renderPromocao(normalized);
      break;
    case "carrinho-abandonado":
      content = renderCarrinhoAbandonado(normalized);
      break;
    default:
      content = `
        <h1 style="margin:0 0 12px;font-size:22px;color:${brand.secondaryColor};">Layout não reconhecido</h1>
        <p style="margin:0;color:${brand.textColor};line-height:1.6;">Informe um layout válido: newsletter, promocao, carrinho-abandonado.</p>
      `;
      break;
  }

  return `${renderHeader({ brand, subject: payload.subject, preheader: payload.preheader })}
    ${content}
  ${renderFooter({ brand })}`.trim();
}

module.exports = {
  generateEmailHtml,
};
