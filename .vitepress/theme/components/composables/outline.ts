
export function getHeaders() {
  const headers = [...document.querySelectorAll('.content h2,h3,h4,h5,h6')]
    .filter((el) => el.id && el.hasChildNodes())
    .map((el) => {
      const level = Number(el.tagName[1])
      return {
        title: serializeHeader(el),
        link: '#' + el.id,
        level
      }
    })

  return headers
}

function serializeHeader(h: Element): string {
  let ret = ''
  for (const node of h.childNodes) {
    if (node.nodeType === 1) {
      if (
        (node as Element).classList.contains('VPBadge') ||
        (node as Element).classList.contains('header-anchor')
      ) {
        continue
      }
      ret += node.textContent
    } else if (node.nodeType === 3) {
      ret += node.textContent
    }
  }
  return ret.trim()
}