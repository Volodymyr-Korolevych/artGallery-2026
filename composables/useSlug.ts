export function useSlug() {
  const slugify = (s: string) =>
    s
      .normalize('NFKD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-zA-Z0-9\s-]/g, '')
      .trim()
      .toLowerCase()
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
  return { slugify }
}
