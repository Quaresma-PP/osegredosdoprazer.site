-- ═══════════════════════════════════════════════════════════════
--  SCHEMA — Conexão Prosperidade
--  Execute este SQL no painel do Supabase: SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════

-- Tabela principal de compradores
CREATE TABLE IF NOT EXISTS compradores (
  id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  email       TEXT        NOT NULL,
  produto_id  TEXT        NOT NULL,
  ativo       BOOLEAN     DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT compradores_unique UNIQUE (email, produto_id)
);

-- Índice para buscas rápidas por email
CREATE INDEX IF NOT EXISTS idx_compradores_email ON compradores(email);

-- Atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION fn_update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_compradores_updated_at ON compradores;
CREATE TRIGGER trg_compradores_updated_at
  BEFORE UPDATE ON compradores
  FOR EACH ROW EXECUTE FUNCTION fn_update_updated_at();

-- Row Level Security: apenas o service key (server-side) tem acesso
ALTER TABLE compradores ENABLE ROW LEVEL SECURITY;

-- Bloqueia acesso público (anon key). O service key bypassa o RLS.
CREATE POLICY "Apenas service key"
  ON compradores FOR ALL
  USING (false);

-- ───────────────────────────────────────────────────────────────
--  INSERIR ACESSO ADMIN MANUALMENTE (opcional)
--  Substitua pelo seu email real antes de rodar
-- ───────────────────────────────────────────────────────────────
-- INSERT INTO compradores (email, produto_id) VALUES
--   ('seuemail@gmail.com', 'poder-dos-arcanjos'),
--   ('seuemail@gmail.com', '30-oracoes-sao-francisco'),
--   ('seuemail@gmail.com', 'musicas-dos-anjos-premium'),
--   ('seuemail@gmail.com', 'grimorio-dos-arcanjos')
-- ON CONFLICT DO NOTHING;
