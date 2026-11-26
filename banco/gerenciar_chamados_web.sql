-- ============================================================================
-- GERENCIAR CHAMADOS WEB - Criação do banco (MySQL 8 / phpMyAdmin)
-- Banco NOVO e separado do SGCTI desktop. Não é migração.
-- ATENÇÃO: senhas em texto puro (decisão do projeto). Não usar com dados reais.
-- ============================================================================
-- DROP DATABASE IF EXISTS gerenciar_chamados_web;   -- APAGA tudo; descomente só para recriar

CREATE DATABASE IF NOT EXISTS gerenciar_chamados_web
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gerenciar_chamados_web;

-- ============================================================================
-- TABELA usuario (14 atributos)
-- perfil: 'TI' (equipe de suporte) ou 'SOLICITANTE' (abre chamados)
-- ============================================================================
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario       INT AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    email            VARCHAR(120) NOT NULL UNIQUE,
    senha            VARCHAR(100) NOT NULL,
    perfil           VARCHAR(15)  NOT NULL DEFAULT 'SOLICITANTE',
    matricula        VARCHAR(20)  NOT NULL UNIQUE,
    setor            VARCHAR(60)  NOT NULL,
    cargo            VARCHAR(60)  NULL,
    telefone         VARCHAR(20)  NULL,
    especialidade    VARCHAR(60)  NULL,            -- preenchida só para perfil TI
    ativo            BOOLEAN      NOT NULL DEFAULT TRUE,
    data_cadastro    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao DATETIME     NULL ON UPDATE CURRENT_TIMESTAMP,
    ultimo_acesso    DATETIME     NULL,
    CONSTRAINT chk_perfil CHECK (perfil IN ('SOLICITANTE', 'TI'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================================
-- TABELA chamados (17 atributos)
-- Padrão ITIL 4: prioridade = impacto x urgência (matriz na regra de negócio)
--   tipo: 'Incidente' (algo parou) ou 'Requisição de serviço' (pedido/dúvida)
--   sla_horas é definido pela prioridade: P1=4h, P2=8h, P3=24h, P4=72h
-- ============================================================================
CREATE TABLE IF NOT EXISTS chamados (
    id_chamado       INT AUTO_INCREMENT PRIMARY KEY,
    titulo           VARCHAR(100) NOT NULL,
    descricao        TEXT         NOT NULL,
    tipo             VARCHAR(25)  NOT NULL DEFAULT 'Incidente',
    categoria        VARCHAR(30)  NOT NULL,
    impacto          VARCHAR(10)  NOT NULL,
    urgencia         VARCHAR(10)  NOT NULL,
    prioridade       VARCHAR(2)   NOT NULL,
    status           VARCHAR(25)  NOT NULL DEFAULT 'Aberto',
    sla_horas        INT          NOT NULL,
    data_abertura    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao DATETIME     NULL ON UPDATE CURRENT_TIMESTAMP,
    data_conclusao   DATETIME     NULL,
    solucao_resumo   VARCHAR(255) NULL,            -- obrigatória para concluir (regra de negócio)
    observacao       TEXT         NULL,
    id_usuario       INT          NOT NULL,        -- solicitante
    id_tecnico       INT          NULL,            -- NULL até um técnico assumir
    CONSTRAINT fk_chamado_solicitante FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_chamado_tecnico     FOREIGN KEY (id_tecnico) REFERENCES usuario(id_usuario) ON DELETE SET NULL,
    CONSTRAINT chk_tipo       CHECK (tipo IN ('Incidente', 'Requisição de serviço')),
    CONSTRAINT chk_categoria  CHECK (categoria IN ('Hardware', 'Software / Sistema', 'Rede / Acesso',
                                                   'Impressora / Periféricos', 'Solicitação / Dúvida')),
    CONSTRAINT chk_impacto    CHECK (impacto IN ('Alto', 'Médio', 'Baixo')),
    CONSTRAINT chk_urgencia   CHECK (urgencia IN ('Alta', 'Média', 'Baixa')),
    CONSTRAINT chk_prioridade CHECK (prioridade IN ('P1', 'P2', 'P3', 'P4')),
    CONSTRAINT chk_status     CHECK (status IN ('Aberto', 'Em análise', 'Em andamento',
                                                'Aguardando usuário', 'Concluído'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================================
-- TABELA pesquisa (15 atributos)
-- Uma pesquisa por chamado (UNIQUE em id_chamado).
-- Respostas q1..q8 aceitam somente 1, 2, 3 ou 4 (cada pergunta tem 4 opções).
-- id_tecnico guarda quem resolveu no momento da resposta (se o chamado for
-- reatribuído depois, o histórico continua correto).
-- ============================================================================
CREATE TABLE IF NOT EXISTS pesquisa (
    id_pesquisa   INT AUTO_INCREMENT PRIMARY KEY,
    id_chamado    INT      NOT NULL UNIQUE,
    id_usuario    INT      NOT NULL,              -- quem respondeu (solicitante)
    id_tecnico    INT      NOT NULL,              -- quem resolveu
    data_resposta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    q1 TINYINT NOT NULL,
    q2 TINYINT NOT NULL,
    q3 TINYINT NOT NULL,
    q4 TINYINT NOT NULL,
    q5 TINYINT NOT NULL,
    q6 TINYINT NOT NULL,
    q7 TINYINT NOT NULL,
    q8 TINYINT NOT NULL,
    observacao    VARCHAR(255) NULL,
    CONSTRAINT fk_pesquisa_chamado FOREIGN KEY (id_chamado) REFERENCES chamados(id_chamado),
    CONSTRAINT fk_pesquisa_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_pesquisa_tecnico FOREIGN KEY (id_tecnico) REFERENCES usuario(id_usuario),
    CONSTRAINT chk_q1 CHECK (q1 BETWEEN 1 AND 4),
    CONSTRAINT chk_q2 CHECK (q2 BETWEEN 1 AND 4),
    CONSTRAINT chk_q3 CHECK (q3 BETWEEN 1 AND 4),
    CONSTRAINT chk_q4 CHECK (q4 BETWEEN 1 AND 4),
    CONSTRAINT chk_q5 CHECK (q5 BETWEEN 1 AND 4),
    CONSTRAINT chk_q6 CHECK (q6 BETWEEN 1 AND 4),
    CONSTRAINT chk_q7 CHECK (q7 BETWEEN 1 AND 4),
    CONSTRAINT chk_q8 CHECK (q8 BETWEEN 1 AND 4)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================================
-- DADOS DE TESTE (opcional). Senha de todos: Teste@123
-- ============================================================================
INSERT INTO usuario (nome, email, senha, perfil, matricula, setor, cargo, telefone, especialidade) VALUES
 ('Ana Técnica',       'ti1@teste.com',  'Teste@123', 'TI',          'TI001',  'TI',         'Analista de Suporte', '(11) 90000-0001', 'Redes'),
 ('Bruno Técnico',     'ti2@teste.com',  'Teste@123', 'TI',          'TI002',  'TI',         'Técnico de Suporte',  '(11) 90000-0002', 'Hardware'),
 ('Carla Solicitante', 'user@teste.com', 'Teste@123', 'SOLICITANTE', 'SOL001', 'Financeiro', 'Assistente',         '(11) 90000-0003', NULL),
 ('Diego Solicitante', 'user2@teste.com','Teste@123', 'SOLICITANTE', 'SOL002', 'RH',         'Analista',            '(11) 90000-0004', NULL);

-- Prioridade P1=4h, P2=8h, P3=24h, P4=72h (sla_horas)
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      solucao_resumo, id_usuario, id_tecnico, data_conclusao)
SELECT 'Computador não liga', 'Máquina da sala 2 sem energia.', 'Incidente', 'Hardware',
       'Alto', 'Alta', 'P1', 'Aberto', 4, NULL, id_usuario, NULL, NULL
FROM usuario WHERE email = 'user@teste.com';

INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      solucao_resumo, id_usuario, id_tecnico, data_conclusao)
SELECT 'Instalar impressora', 'Driver da impressora nova.', 'Requisição de serviço', 'Impressora / Periféricos',
       'Baixo', 'Baixa', 'P4', 'Em andamento', 72, NULL, s.id_usuario, t.id_usuario, NULL
FROM usuario s, usuario t WHERE s.email = 'user2@teste.com' AND t.email = 'ti2@teste.com';

INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      solucao_resumo, id_usuario, id_tecnico, data_conclusao)
SELECT 'Acesso ao ERP', 'Liberar acesso ao ERP.', 'Requisição de serviço', 'Rede / Acesso',
       'Médio', 'Média', 'P3', 'Concluído', 24, 'Acesso liberado pelo perfil financeiro.',
       s.id_usuario, t.id_usuario, NOW()
FROM usuario s, usuario t WHERE s.email = 'user@teste.com' AND t.email = 'ti1@teste.com';

INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      solucao_resumo, id_usuario, id_tecnico, data_conclusao)
SELECT 'Sem internet na sala 3', 'Sala inteira sem acesso à rede desde as 8h.', 'Incidente', 'Rede / Acesso',
       'Alto', 'Alta', 'P1', 'Aguardando usuário', 4, NULL, s.id_usuario, t.id_usuario, NULL
FROM usuario s, usuario t WHERE s.email = 'user2@teste.com' AND t.email = 'ti1@teste.com';

-- Pesquisa de exemplo para o chamado concluído (respostas 1 a 4)
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
SELECT c.id_chamado, c.id_usuario, c.id_tecnico, 4, 3, 4, 4, 3, 4, 4, 3, 'Atendimento rápido.'
FROM chamados c WHERE c.titulo = 'Acesso ao ERP';

-- ============================================================================
-- CONSULTAS DOS RELATÓRIOS (referência; o sistema Java executa as mesmas)
-- ============================================================================

-- Relatório 1: cada entrevistado e suas respostas
SELECT u.nome, c.titulo, p.q1, p.q2, p.q3, p.q4, p.q5, p.q6, p.q7, p.q8, p.data_resposta
FROM pesquisa p
JOIN usuario u ON p.id_usuario = u.id_usuario
JOIN chamados c ON p.id_chamado = c.id_chamado
ORDER BY u.nome;

-- Relatório 2: total de entrevistados
SELECT COUNT(*) AS total_entrevistados FROM pesquisa;

-- Relatório 2: percentual de cada alternativa na questão 1 (repetir para q2 a q8)
SELECT
  ROUND(100 * SUM(q1 = 1) / COUNT(*), 1) AS pct_opcao_1,
  ROUND(100 * SUM(q1 = 2) / COUNT(*), 1) AS pct_opcao_2,
  ROUND(100 * SUM(q1 = 3) / COUNT(*), 1) AS pct_opcao_3,
  ROUND(100 * SUM(q1 = 4) / COUNT(*), 1) AS pct_opcao_4
FROM pesquisa;

-- Painel: chamados por status (status sem registros aparecem como 0 no Java)
SELECT status, COUNT(*) AS quantidade FROM chamados GROUP BY status;
