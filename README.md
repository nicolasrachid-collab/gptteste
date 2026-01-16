# Gerador de HTML para E-mails

Este projeto gera HTML de e-mail a partir de um payload JSON. Ele inclui uma CLI simples para receber o payload e devolver o HTML pronto.

## Requisitos

- Node.js 18+

## Uso rápido (CLI)

```bash
node src/cli.js --input examples/newsletter.json --output dist/newsletter.html
```

Ou via `stdin`:

```bash
cat examples/promocao.json | node src/cli.js > dist/promocao.html
```

## API rápida (HTTP)

Suba um servidor local que aceita `POST /render` com JSON e devolve o HTML:

```bash
node src/server.js
```

Em outro terminal, envie o payload:

```bash
curl -X POST http://localhost:3000/render \
  -H "Content-Type: application/json" \
  --data @examples/carrinho-abandonado.json \
  -o dist/carrinho-abandonado.html
```

## Payload (exemplo resumido)

```json
{
  "layout": "newsletter",
  "subject": "Resumo semanal",
  "preheader": "Histórias e novidades.",
  "brand": {
    "name": "Aurora Coffee",
    "primaryColor": "#8B5CF6"
  },
  "hero": {
    "title": "Bem-vindo à newsletter",
    "subtitle": "Tendências em cafés especiais.",
    "cta": {
      "text": "Ler o blog",
      "url": "https://auroracoffee.example.com/blog"
    }
  }
}
```

## Exemplos completos

Os exemplos abaixo incluem o payload JSON e o HTML gerado:

- Newsletter: `examples/newsletter.json` → `examples/newsletter.html`
- Promoção: `examples/promocao.json` → `examples/promocao.html`
- Carrinho abandonado: `examples/carrinho-abandonado.json` → `examples/carrinho-abandonado.html`

## Exemplos de saída (trechos)

### Newsletter

```html
<h1 style="margin:0 0 12px;font-size:24px;color:#1F2937;">Bem-vindo à nossa newsletter</h1>
<p style="margin:0 0 20px;color:#111827;line-height:1.6;">Tendências em cafés especiais, dicas de preparo e histórias dos produtores.</p>
```

### Promoção

```html
<div style="font-size:32px;font-weight:700;color:#EF4444;">35% OFF</div>
```

### Carrinho abandonado

```html
<td style="padding:12px 0;font-weight:700;">Total</td>
<td align="right" style="padding:12px 0;font-weight:700;">R$ 948,00</td>
```

## Dicas para validação rápida

1. Abra o arquivo `.html` gerado no navegador.
2. Confira o assunto no topo, o botão de CTA e o rodapé da marca.
3. Caso queira alterar cores e textos, edite o JSON e gere novamente.
