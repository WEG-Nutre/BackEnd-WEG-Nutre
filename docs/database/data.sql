BEGIN;

-- =========================================================
-- USUÁRIOS
-- =========================================================

CREATE TABLE tb_usuario_nutricionista (
    id_usuario_nutricionista UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nome          VARCHAR(150) NOT NULL,
    email         VARCHAR(254) NOT NULL UNIQUE,
    login         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    matricula     VARCHAR(30) NOT NULL UNIQUE,
    crn           VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE tb_usuario_ti (
    id_usuario_ti UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nome          VARCHAR(150) NOT NULL,
    email         VARCHAR(254) NOT NULL UNIQUE,
    login         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE tb_usuario_colaborador (
    id_usuario_colaborador UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nome          VARCHAR(150) NOT NULL,
    email         VARCHAR(254) NOT NULL UNIQUE,
    login         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    matricula     VARCHAR(30) NOT NULL UNIQUE,
    crn           VARCHAR(30)
);

COMMENT ON COLUMN tb_usuario_nutricionista.password_hash IS
    'Armazena exclusivamente o hash da senha gerado pela aplicação; nunca texto puro.';

COMMENT ON COLUMN tb_usuario_ti.password_hash IS
    'Armazena exclusivamente o hash da senha gerado pela aplicação; nunca texto puro.';

COMMENT ON COLUMN tb_usuario_colaborador.password_hash IS
    'Armazena exclusivamente o hash da senha gerado pela aplicação; nunca texto puro.';

COMMENT ON COLUMN tb_usuario_colaborador.crn IS
    'Mantido conforme o DER. Confirmar se se aplica ao colaborador.';


-- =========================================================
-- FEEDBACK
-- =========================================================

CREATE TABLE tb_feedback (
    id_feedback UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    descricao TEXT,
    nota      NUMERIC(5, 2) NOT NULL,

    CONSTRAINT ck_feedback_nota
        CHECK (nota >= 0)
);


-- =========================================================
-- ALÉRGENOS
-- =========================================================

CREATE TABLE tb_alergeno (
    id_alergeno UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nome VARCHAR(100) NOT NULL
);


-- =========================================================
-- INGREDIENTES
-- =========================================================

CREATE TABLE tb_ingrediente (
    id_ingrediente UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nome           VARCHAR(150) NOT NULL,
    preco          NUMERIC(10, 2) NOT NULL,
    "unidadeMedida" VARCHAR(20) NOT NULL,
    quantidade     NUMERIC(12, 3) NOT NULL,
    vegetariano    BOOLEAN NOT NULL DEFAULT FALSE,

    calorias       NUMERIC(12, 3),
    proteinas      NUMERIC(12, 3),
    gorduras       NUMERIC(12, 3),
    carboidratos   NUMERIC(12, 3),

    CONSTRAINT ck_ingrediente_preco
        CHECK (preco >= 0),

    CONSTRAINT ck_ingrediente_quantidade
        CHECK (quantidade >= 0),

    CONSTRAINT ck_ingrediente_calorias
        CHECK (calorias >= 0),

    CONSTRAINT ck_ingrediente_proteinas
        CHECK (proteinas >= 0),

    CONSTRAINT ck_ingrediente_gorduras
        CHECK (gorduras >= 0),

    CONSTRAINT ck_ingrediente_carboidratos
        CHECK (carboidratos >= 0)
);


-- =========================================================
-- PRATOS
-- =========================================================

CREATE TABLE tb_prato (
    id_prato UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nome            VARCHAR(150) NOT NULL,
    descricao       TEXT,
    preco           NUMERIC(10, 2) NOT NULL,
    porcao_gramas    NUMERIC(12, 3) NOT NULL,

    calorias        NUMERIC(12, 3),
    proteinas       NUMERIC(12, 3),
    gorduras        NUMERIC(12, 3),
    carboidratos    NUMERIC(12, 3),

    categoria_prato VARCHAR(100) NOT NULL,
    modo_de_preparo TEXT,

    CONSTRAINT ck_prato_preco
        CHECK (preco >= 0),

    CONSTRAINT ck_prato_porcao
        CHECK (porcao_gramas > 0),

    CONSTRAINT ck_prato_calorias
        CHECK (calorias >= 0),

    CONSTRAINT ck_prato_proteinas
        CHECK (proteinas >= 0),

    CONSTRAINT ck_prato_gorduras
        CHECK (gorduras >= 0),

    CONSTRAINT ck_prato_carboidratos
        CHECK (carboidratos >= 0)
);


-- =========================================================
-- CARDÁPIOS
-- =========================================================

CREATE TABLE tb_cardapio (
    id_cardapio UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    nutricionista        UUID NOT NULL,
    data                 DATE NOT NULL,
    "metaTetoCusto"       NUMERIC(10, 2) NOT NULL,
    aprovado             BOOLEAN NOT NULL DEFAULT FALSE,
    "quantidadeRefeicoes" INTEGER NOT NULL,
    nota                 NUMERIC(5, 2),
    "qtdProduzida"        INTEGER,
    "qtdDesperdicio"      INTEGER,
    "qtdExcedente"        INTEGER,

    CONSTRAINT fk_cardapio_nutricionista
        FOREIGN KEY (nutricionista)
        REFERENCES tb_usuario_nutricionista (
            id_usuario_nutricionista
        )
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT ck_cardapio_meta
        CHECK ("metaTetoCusto" >= 0),

    CONSTRAINT ck_cardapio_refeicoes
        CHECK ("quantidadeRefeicoes" >= 0),

    CONSTRAINT ck_cardapio_nota
        CHECK (nota >= 0),

    CONSTRAINT ck_cardapio_produzida
        CHECK ("qtdProduzida" >= 0),

    CONSTRAINT ck_cardapio_desperdicio
        CHECK ("qtdDesperdicio" >= 0),

    CONSTRAINT ck_cardapio_excedente
        CHECK ("qtdExcedente" >= 0)
);


-- =========================================================
-- RELACIONAMENTO: PRATO × CARDÁPIO
-- =========================================================

CREATE TABLE tb_prato_cardapio (
    id_prato_cardapio UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    id_prato    UUID NOT NULL,
    id_cardapio UUID NOT NULL,

    CONSTRAINT fk_prato_cardapio_prato
        FOREIGN KEY (id_prato)
        REFERENCES tb_prato (id_prato)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_prato_cardapio_cardapio
        FOREIGN KEY (id_cardapio)
        REFERENCES tb_cardapio (id_cardapio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT uq_prato_cardapio
        UNIQUE (id_prato, id_cardapio)
);


-- =========================================================
-- RELACIONAMENTO: PRATO × INGREDIENTE
-- =========================================================

CREATE TABLE tb_prato_ingrediente (
    id_prato_ingrediente UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    id_prato       UUID NOT NULL,
    id_ingrediente UUID NOT NULL,
    porcao         NUMERIC(12, 3) NOT NULL,

    CONSTRAINT fk_prato_ingrediente_prato
        FOREIGN KEY (id_prato)
        REFERENCES tb_prato (id_prato)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_prato_ingrediente_ingrediente
        FOREIGN KEY (id_ingrediente)
        REFERENCES tb_ingrediente (id_ingrediente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT uq_prato_ingrediente
        UNIQUE (id_prato, id_ingrediente),

    CONSTRAINT ck_prato_ingrediente_porcao
        CHECK (porcao > 0)
);


-- =========================================================
-- RELACIONAMENTO: PRATO × ALÉRGENO
-- =========================================================

CREATE TABLE tb_prato_alergeno (
    id_prato_alergeno UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    id_prato    UUID NOT NULL,
    id_alergeno UUID NOT NULL,

    CONSTRAINT fk_prato_alergeno_prato
        FOREIGN KEY (id_prato)
        REFERENCES tb_prato (id_prato)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_prato_alergeno_alergeno
        FOREIGN KEY (id_alergeno)
        REFERENCES tb_alergeno (id_alergeno)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT uq_prato_alergeno
        UNIQUE (id_prato, id_alergeno)
);


-- =========================================================
-- RELACIONAMENTO: FEEDBACK × PRATO
-- =========================================================

CREATE TABLE tb_feedback_prato (
    id_feedback_prato UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    id_prato    UUID NOT NULL,
    id_feedback UUID NOT NULL,

    CONSTRAINT fk_feedback_prato_prato
        FOREIGN KEY (id_prato)
        REFERENCES tb_prato (id_prato)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_feedback_prato_feedback
        FOREIGN KEY (id_feedback)
        REFERENCES tb_feedback (id_feedback)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT uq_feedback_prato
        UNIQUE (id_prato, id_feedback)
);


-- =========================================================
-- ÍNDICES DAS CHAVES ESTRANGEIRAS
-- PKs e UNIQUEs já criam seus próprios índices.
-- Estes índices cobrem as demais FKs.
-- =========================================================

CREATE INDEX idx_cardapio_nutricionista
    ON tb_cardapio (nutricionista);

CREATE INDEX idx_prato_cardapio_cardapio
    ON tb_prato_cardapio (id_cardapio);

CREATE INDEX idx_prato_ingrediente_ingrediente
    ON tb_prato_ingrediente (id_ingrediente);

CREATE INDEX idx_prato_alergeno_alergeno
    ON tb_prato_alergeno (id_alergeno);

CREATE INDEX idx_feedback_prato_feedback
    ON tb_feedback_prato (id_feedback);

COMMIT;