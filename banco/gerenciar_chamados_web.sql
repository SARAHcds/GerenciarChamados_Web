
CREATE DATABASE IF NOT EXISTS gerenciar_chamados_web
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gerenciar_chamados_web;


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
    especialidade    VARCHAR(60)  NULL,            
    ativo            BOOLEAN      NOT NULL DEFAULT TRUE,
    data_cadastro    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao DATETIME     NULL ON UPDATE CURRENT_TIMESTAMP,
    ultimo_acesso    DATETIME     NULL,
    CONSTRAINT chk_perfil CHECK (perfil IN ('SOLICITANTE', 'TI'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


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
    solucao_resumo   VARCHAR(255) NULL,            
    observacao       TEXT         NULL,
    id_usuario       INT          NOT NULL,        
    id_tecnico       INT          NULL,            
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


CREATE TABLE IF NOT EXISTS pesquisa (
    id_pesquisa   INT AUTO_INCREMENT PRIMARY KEY,
    id_chamado    INT      NOT NULL UNIQUE,
    id_usuario    INT      NOT NULL,              
    id_tecnico    INT      NOT NULL,              
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


-- ============================================================================
-- DADOS DE TESTE. Senha de todos: Teste@123
-- ============================================================================
INSERT INTO usuario (nome, email, senha, perfil, matricula, setor, cargo, telefone, especialidade) VALUES
 ('Ana Técnica',       'ti1@teste.com',  'Teste@123', 'TI',          'TI001',  'TI',         'Analista de Suporte', '(11) 90000-0001', 'Redes'),
 ('Bruno Técnico',     'ti2@teste.com',  'Teste@123', 'TI',          'TI002',  'TI',         'Técnico de Suporte',  '(11) 90000-0002', 'Hardware'),
 ('Carla Solicitante', 'user@teste.com', 'Teste@123', 'SOLICITANTE', 'SOL001', 'Financeiro', 'Assistente',         '(11) 90000-0003', NULL),
 ('Diego Solicitante', 'user2@teste.com','Teste@123', 'SOLICITANTE', 'SOL002', 'RH',         'Analista',            '(11) 90000-0004', NULL);


USE gerenciar_chamados_web;
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- 1) LIMPEZA dos dados de demonstração anteriores (ordem: pesquisa -> chamados -> usuario)
-- ---------------------------------------------------------------------------
DELETE p FROM pesquisa p
  JOIN chamados c ON p.id_chamado = c.id_chamado
  JOIN usuario s ON c.id_usuario = s.id_usuario
 WHERE s.email LIKE '%@empresa.com';

DELETE p FROM pesquisa p
  JOIN usuario t ON p.id_tecnico = t.id_usuario
 WHERE t.email LIKE '%@empresa.com';

DELETE c FROM chamados c
  JOIN usuario s ON c.id_usuario = s.id_usuario
 WHERE s.email LIKE '%@empresa.com';

UPDATE chamados c
  JOIN usuario t ON c.id_tecnico = t.id_usuario
   SET c.id_tecnico = NULL
 WHERE t.email LIKE '%@empresa.com';

DELETE FROM usuario WHERE email LIKE '%@empresa.com';

-- ---------------------------------------------------------------------------
-- 2) USUÁRIOS - 3 técnicos (perfil TI) e 7 solicitantes
-- ---------------------------------------------------------------------------
INSERT INTO usuario (nome, email, senha, perfil, matricula, setor, cargo, telefone, especialidade, ativo, data_cadastro, ultimo_acesso) VALUES
 ('Lucas Mendes', 'lucas@empresa.com', 'Teste@123', 'TI', 'TI101', 'TI', 'Analista de Suporte', '(11) 91000-0101', 'Redes', TRUE, '2025-11-03 09:00:00', '2026-11-25 17:30:00'),
 ('Patrícia Gomes', 'patricia@empresa.com', 'Teste@123', 'TI', 'TI102', 'TI', 'Técnica de Suporte', '(11) 91000-0102', 'Hardware', TRUE, '2025-11-03 09:00:00', '2026-11-25 17:30:00'),
 ('Rafael Costa', 'rafael@empresa.com', 'Teste@123', 'TI', 'TI103', 'TI', 'Analista de Sistemas', '(11) 91000-0103', 'Sistemas', TRUE, '2025-11-03 09:00:00', '2026-11-25 17:30:00'),
 ('Alice Martins', 'alice@empresa.com', 'Teste@123', 'SOLICITANTE', 'SOL101', 'Financeiro', 'Analista Financeira', '(11) 92000-0101', NULL, TRUE, '2025-11-10 10:00:00', '2026-11-24 16:00:00'),
 ('Marcos Oliveira', 'marcos@empresa.com', 'Teste@123', 'SOLICITANTE', 'SOL102', 'Comercial', 'Vendedor', '(11) 92000-0102', NULL, TRUE, '2025-11-10 10:00:00', '2026-11-24 16:00:00'),
 ('Juliana Ferreira', 'juliana@empresa.com', 'Teste@123', 'SOLICITANTE', 'SOL103', 'RH', 'Analista de RH', '(11) 92000-0103', NULL, TRUE, '2025-11-10 10:00:00', '2026-11-24 16:00:00'),
 ('Pedro Santos', 'pedro@empresa.com', 'Teste@123', 'SOLICITANTE', 'SOL104', 'Logística', 'Coordenador', '(11) 92000-0104', NULL, TRUE, '2025-11-10 10:00:00', '2026-11-24 16:00:00'),
 ('Fernanda Lima', 'fernanda@empresa.com', 'Teste@123', 'SOLICITANTE', 'SOL105', 'Contabilidade', 'Contadora', '(11) 92000-0105', NULL, TRUE, '2025-11-10 10:00:00', '2026-11-24 16:00:00'),
 ('Ricardo Alves', 'ricardo@empresa.com', 'Teste@123', 'SOLICITANTE', 'SOL106', 'Jurídico', 'Advogado', '(11) 92000-0106', NULL, TRUE, '2025-11-10 10:00:00', '2026-11-24 16:00:00'),
 ('Camila Rocha', 'camila@empresa.com', 'Teste@123', 'SOLICITANTE', 'SOL107', 'Marketing', 'Designer', '(11) 92000-0107', NULL, TRUE, '2025-11-10 10:00:00', '2026-11-24 16:00:00');

SET @lucas = (SELECT id_usuario FROM usuario WHERE email = 'lucas@empresa.com');
SET @patricia = (SELECT id_usuario FROM usuario WHERE email = 'patricia@empresa.com');
SET @rafael = (SELECT id_usuario FROM usuario WHERE email = 'rafael@empresa.com');
SET @alice = (SELECT id_usuario FROM usuario WHERE email = 'alice@empresa.com');
SET @marcos = (SELECT id_usuario FROM usuario WHERE email = 'marcos@empresa.com');
SET @juliana = (SELECT id_usuario FROM usuario WHERE email = 'juliana@empresa.com');
SET @pedro = (SELECT id_usuario FROM usuario WHERE email = 'pedro@empresa.com');
SET @fernanda = (SELECT id_usuario FROM usuario WHERE email = 'fernanda@empresa.com');
SET @ricardo = (SELECT id_usuario FROM usuario WHERE email = 'ricardo@empresa.com');
SET @camila = (SELECT id_usuario FROM usuario WHERE email = 'camila@empresa.com');

-- ---------------------------------------------------------------------------
-- 3) CHAMADOS e PESQUISAS
-- ---------------------------------------------------------------------------

-- ===== ALICE MARTINS (15 chamados) =====
-- 1º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Computador não liga', 'O computador da minha mesa não liga, nem acende a luz do botão.', 'Incidente', 'Hardware', 'Médio', 'Alta', 'P2', 'Concluído', 8,
        '2025-11-26 13:10:00', '2025-11-27 09:50:00', '2025-11-27 09:50:00', 'Fonte de alimentação substituída.', NULL, @alice, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @patricia, '2025-11-28 10:05:00', 3, 2, 3, 1, 3, 2, 1, 2, NULL);
-- 2º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Sem acesso à internet', 'Estou sem internet desde o início do expediente.', 'Incidente', 'Rede / Acesso', 'Médio', 'Alta', 'P2', 'Concluído', 8,
        '2025-12-23 16:45:00', '2025-12-24 10:05:00', '2025-12-24 10:05:00', 'Cabo de rede reconectado no switch.', NULL, @alice, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @lucas, '2025-12-25 09:35:00', 2, 2, 3, 4, 3, 2, 2, 2, 'O problema voltou alguns dias depois.');
-- 3º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Excel travando', 'O Excel trava ao abrir planilhas grandes.', 'Incidente', 'Software / Sistema', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2026-01-26 16:50:00', '2026-01-30 09:50:00', '2026-01-30 09:50:00', 'Office reparado e suplementos desativados.', NULL, @alice, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @rafael, '2026-02-02 15:50:00', 3, 4, 3, 3, 4, 2, 3, 2, 'Resolveu de primeira.');
-- 4º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Senha do e-mail bloqueada', 'Errei a senha e a conta de e-mail foi bloqueada.', 'Requisição de serviço', 'Rede / Acesso', 'Baixo', 'Alta', 'P3', 'Concluído', 24,
        '2026-02-19 15:20:00', '2026-02-20 09:50:00', '2026-02-20 09:50:00', 'Senha redefinida e conta desbloqueada.', NULL, @alice, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @lucas, '2026-02-23 10:35:00', 2, 3, 3, 2, 4, 2, 2, 4, 'Demorou mais do que eu esperava.');
-- 5º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Impressora não imprime', 'A impressora do setor mostra a fila parada.', 'Incidente', 'Impressora / Periféricos', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-03-12 09:10:00', '2026-03-13 16:10:00', '2026-03-13 16:10:00', 'Fila de impressão limpa e driver reinstalado.', NULL, @alice, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @patricia, '2026-03-16 09:05:00', 3, 4, 3, 2, 2, 2, 3, 3, NULL);
-- 6º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Erro ao abrir o ERP', 'O ERP fecha sozinho ao abrir o módulo de relatórios.', 'Incidente', 'Software / Sistema', 'Alto', 'Alta', 'P1', 'Concluído', 4,
        '2026-04-09 09:50:00', '2026-04-09 10:50:00', '2026-04-09 10:50:00', 'Atualização do ERP aplicada.', NULL, @alice, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @rafael, '2026-04-10 11:50:00', 2, 3, 4, 4, 3, 4, 3, 2, NULL);
-- 7º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Monitor piscando', 'O monitor fica piscando e às vezes apaga sozinho.', 'Incidente', 'Hardware', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2026-05-04 15:40:00', '2026-05-05 13:40:00', '2026-05-05 13:40:00', 'Cabo de vídeo trocado.', NULL, @alice, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @patricia, '2026-05-06 09:40:00', 3, 3, 4, 3, 3, 2, 3, 3, 'Técnico muito atencioso.');
-- 8º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Acesso à pasta compartilhada', 'Preciso de acesso à pasta do setor no servidor.', 'Requisição de serviço', 'Rede / Acesso', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2026-06-01 14:30:00', '2026-06-03 10:20:00', '2026-06-03 10:20:00', 'Permissão concedida ao grupo do setor.', NULL, @alice, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @lucas, '2026-06-03 14:20:00', 4, 3, 4, 3, 2, 4, 3, 3, 'Atendimento rápido.');
-- 9º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Notebook superaquecendo', 'O notebook esquenta muito e desliga sozinho.', 'Incidente', 'Hardware', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-06-29 13:45:00', '2026-07-01 08:35:00', '2026-07-01 08:35:00', 'Limpeza interna e troca da pasta térmica.', NULL, @alice, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @patricia, '2026-07-02 10:20:00', 3, 2, 4, 3, 3, 4, 2, 4, 'Explicou tudo com clareza.');
-- 10º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Backup de arquivos', 'Preciso recuperar uma planilha apagada ontem.', 'Requisição de serviço', 'Software / Sistema', 'Médio', 'Alta', 'P2', 'Concluído', 8,
        '2026-07-27 16:10:00', '2026-07-28 09:50:00', '2026-07-28 09:50:00', 'Arquivo restaurado do backup.', NULL, @alice, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @rafael, '2026-07-28 11:50:00', 3, 3, 4, 4, 4, 4, 4, 4, NULL);
-- 11º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Instalar programa de PDF', 'Preciso de um editor de PDF instalado.', 'Requisição de serviço', 'Software / Sistema', 'Baixo', 'Baixa', 'P4', 'Concluído', 72,
        '2026-08-24 13:10:00', '2026-08-28 10:20:00', '2026-08-28 10:20:00', 'Programa instalado e licenciado.', NULL, @alice, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @rafael, '2026-08-31 14:20:00', 3, 4, 4, 4, 4, 4, 4, 3, NULL);
-- 12º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('VPN não conecta', 'A VPN retorna erro de autenticação em home office.', 'Incidente', 'Rede / Acesso', 'Médio', 'Alta', 'P2', 'Concluído', 8,
        '2026-09-17 16:30:00', '2026-09-18 09:05:00', '2026-09-18 09:05:00', 'Certificado da VPN renovado.', NULL, @alice, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @lucas, '2026-09-21 09:05:00', 4, 4, 4, 4, 4, 4, 4, 4, 'Muito bom, obrigado!');
-- 13º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Dúvida sobre assinatura de e-mail', 'Como configuro a assinatura padrão da empresa?', 'Requisição de serviço', 'Solicitação / Dúvida', 'Baixo', 'Baixa', 'P4', 'Concluído', 72,
        '2026-10-12 15:15:00', '2026-10-16 08:20:00', '2026-10-16 08:20:00', 'Orientação enviada com passo a passo.', NULL, @alice, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @alice, @rafael, '2026-10-19 08:35:00', 4, 4, 3, 4, 3, 3, 4, 3, 'Atendimento rápido.');
-- 14º chamado - Concluído (pesquisa AINDA NÃO respondida)
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Teclado com teclas falhando', 'Algumas teclas não funcionam (A, S e Enter).', 'Incidente', 'Impressora / Periféricos', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2026-11-18 12:00:00', '2026-11-23 16:00:00', '2026-11-23 16:00:00', 'Teclado substituído por um novo.', NULL, @alice, @patricia);
-- 15º chamado - Aberto
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Wi-Fi da sala de reunião caindo', 'A rede sem fio cai durante as reuniões.', 'Incidente', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Aberto', 24,
        '2026-11-24 13:40:00', NULL, NULL, NULL, NULL, @alice, NULL);

-- ===== MARCOS OLIVEIRA (8 chamados) =====
-- 1º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Liberar acesso ao sistema de vendas', 'Novo colaborador precisa de acesso ao sistema.', 'Requisição de serviço', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-01-14 10:10:00', '2026-01-15 09:20:00', '2026-01-15 09:20:00', 'Usuário criado no sistema de vendas.', NULL, @marcos, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @marcos, @lucas, '2026-01-16 09:50:00', 3, 3, 3, 4, 4, 4, 4, 4, 'Atendimento rápido.');
-- 2º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Senha do e-mail bloqueada', 'Errei a senha e a conta de e-mail foi bloqueada.', 'Requisição de serviço', 'Rede / Acesso', 'Baixo', 'Alta', 'P3', 'Concluído', 24,
        '2026-01-16 08:00:00', '2026-01-19 09:05:00', '2026-01-19 09:05:00', 'Senha redefinida e conta desbloqueada.', NULL, @marcos, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @marcos, @lucas, '2026-01-20 15:05:00', 4, 4, 4, 3, 3, 4, 3, 3, 'Atendimento rápido.');
-- 3º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Impressora não imprime', 'A impressora do setor mostra a fila parada.', 'Incidente', 'Impressora / Periféricos', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-02-02 14:40:00', '2026-02-03 08:40:00', '2026-02-03 08:40:00', 'Fila de impressão limpa e driver reinstalado.', NULL, @marcos, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @marcos, @patricia, '2026-02-04 08:40:00', 3, 3, 3, 4, 4, 3, 3, 4, 'Atendimento rápido.');
-- 4º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Wi-Fi da sala de reunião caindo', 'A rede sem fio cai durante as reuniões.', 'Incidente', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-04-10 14:00:00', '2026-04-13 15:00:00', '2026-04-13 15:00:00', 'Access point reconfigurado em outro canal.', NULL, @marcos, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @marcos, @lucas, '2026-04-14 10:05:00', 3, 4, 4, 3, 4, 3, 4, 3, 'Resolveu de primeira.');
-- 5º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Backup de arquivos', 'Preciso recuperar uma planilha apagada ontem.', 'Requisição de serviço', 'Software / Sistema', 'Médio', 'Alta', 'P2', 'Concluído', 8,
        '2026-04-13 09:15:00', '2026-04-13 12:15:00', '2026-04-13 12:15:00', 'Arquivo restaurado do backup.', NULL, @marcos, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @marcos, @rafael, '2026-04-14 09:20:00', 4, 4, 2, 3, 3, 4, 4, 4, 'Explicou tudo com clareza.');
-- 6º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Erro ao abrir o ERP', 'O ERP fecha sozinho ao abrir o módulo de relatórios.', 'Incidente', 'Software / Sistema', 'Alto', 'Alta', 'P1', 'Concluído', 4,
        '2026-07-07 10:15:00', '2026-07-07 11:15:00', '2026-07-07 11:15:00', 'Atualização do ERP aplicada.', NULL, @marcos, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @marcos, @rafael, '2026-07-08 09:20:00', 3, 3, 2, 3, 4, 3, 4, 4, 'Explicou tudo com clareza.');
-- 7º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Sem acesso à internet', 'Estou sem internet desde o início do expediente.', 'Incidente', 'Rede / Acesso', 'Médio', 'Alta', 'P2', 'Concluído', 8,
        '2026-09-07 09:15:00', '2026-09-07 11:15:00', '2026-09-07 11:15:00', 'Cabo de rede reconectado no switch.', NULL, @marcos, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @marcos, @lucas, '2026-09-08 09:05:00', 4, 3, 4, 3, 3, 3, 4, 4, NULL);
-- 8º chamado - Em andamento
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Como usar a nova impressora', 'Não sei escanear para o e-mail na impressora nova.', 'Requisição de serviço', 'Solicitação / Dúvida', 'Baixo', 'Baixa', 'P4', 'Em andamento', 72,
        '2026-11-23 16:15:00', '2026-11-24 09:35:00', NULL, NULL, NULL, @marcos, @patricia);

-- ===== JULIANA FERREIRA (7 chamados) =====
-- 1º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Acesso à pasta compartilhada', 'Preciso de acesso à pasta do setor no servidor.', 'Requisição de serviço', 'Rede / Acesso', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2026-07-20 12:20:00', '2026-07-23 11:20:00', '2026-07-23 11:20:00', 'Permissão concedida ao grupo do setor.', NULL, @juliana, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @juliana, @lucas, '2026-07-24 09:35:00', 4, 4, 4, 3, 4, 3, 4, 3, 'Atendimento rápido.');
-- 2º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Liberar acesso ao sistema de vendas', 'Novo colaborador precisa de acesso ao sistema.', 'Requisição de serviço', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-07-20 10:10:00', '2026-07-21 10:35:00', '2026-07-21 10:35:00', 'Usuário criado no sistema de vendas.', NULL, @juliana, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @juliana, @lucas, '2026-07-21 15:35:00', 2, 3, 3, 4, 3, 4, 4, 4, 'Atendimento rápido.');
-- 3º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Wi-Fi da sala de reunião caindo', 'A rede sem fio cai durante as reuniões.', 'Incidente', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-07-27 14:40:00', '2026-07-28 10:20:00', '2026-07-28 10:20:00', 'Access point reconfigurado em outro canal.', NULL, @juliana, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @juliana, @lucas, '2026-07-29 09:50:00', 4, 4, 3, 4, 4, 4, 4, 4, 'Muito bom, obrigado!');
-- 4º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Excel travando', 'O Excel trava ao abrir planilhas grandes.', 'Incidente', 'Software / Sistema', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2026-09-02 13:15:00', '2026-09-04 10:20:00', '2026-09-04 10:20:00', 'Office reparado e suplementos desativados.', NULL, @juliana, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @juliana, @rafael, '2026-09-07 08:20:00', 4, 4, 2, 4, 4, 4, 3, 4, 'Técnico muito atencioso.');
-- 5º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Senha do e-mail bloqueada', 'Errei a senha e a conta de e-mail foi bloqueada.', 'Requisição de serviço', 'Rede / Acesso', 'Baixo', 'Alta', 'P3', 'Concluído', 24,
        '2026-09-21 10:10:00', '2026-09-22 10:05:00', '2026-09-22 10:05:00', 'Senha redefinida e conta desbloqueada.', NULL, @juliana, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @juliana, @lucas, '2026-09-23 13:05:00', 3, 4, 3, 3, 4, 4, 3, 4, NULL);
-- 6º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('VPN não conecta', 'A VPN retorna erro de autenticação em home office.', 'Incidente', 'Rede / Acesso', 'Médio', 'Alta', 'P2', 'Concluído', 8,
        '2026-10-19 15:40:00', '2026-10-20 08:50:00', '2026-10-20 08:50:00', 'Certificado da VPN renovado.', NULL, @juliana, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @juliana, @lucas, '2026-10-21 12:50:00', 4, 3, 4, 3, 3, 4, 3, 4, NULL);
-- 7º chamado - Aguardando usuário
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Como usar a nova impressora', 'Não sei escanear para o e-mail na impressora nova.', 'Requisição de serviço', 'Solicitação / Dúvida', 'Baixo', 'Baixa', 'P4', 'Aguardando usuário', 72,
        '2026-11-23 14:40:00', '2026-11-23 16:40:00', NULL, NULL, 'Aguardando o usuário informar o melhor horário para atendimento.', @juliana, @patricia);

-- ===== PEDRO SANTOS (6 chamados) =====
-- 1º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Senha do e-mail bloqueada', 'Errei a senha e a conta de e-mail foi bloqueada.', 'Requisição de serviço', 'Rede / Acesso', 'Baixo', 'Alta', 'P3', 'Concluído', 24,
        '2026-02-13 10:45:00', '2026-02-16 08:35:00', '2026-02-16 08:35:00', 'Senha redefinida e conta desbloqueada.', NULL, @pedro, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @pedro, @lucas, '2026-02-17 10:50:00', 3, 4, 3, 4, 3, 3, 4, 4, 'Resolveu de primeira.');
-- 2º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Como usar a nova impressora', 'Não sei escanear para o e-mail na impressora nova.', 'Requisição de serviço', 'Solicitação / Dúvida', 'Baixo', 'Baixa', 'P4', 'Concluído', 72,
        '2026-03-16 14:45:00', '2026-03-19 09:50:00', '2026-03-19 09:50:00', 'Usuário orientado presencialmente.', NULL, @pedro, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @pedro, @patricia, '2026-03-20 09:35:00', 2, 4, 4, 2, 4, 2, 3, 2, 'Técnico muito atencioso.');
-- 3º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Acesso à pasta compartilhada', 'Preciso de acesso à pasta do setor no servidor.', 'Requisição de serviço', 'Rede / Acesso', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2026-06-09 08:45:00', '2026-06-11 09:35:00', '2026-06-11 09:35:00', 'Permissão concedida ao grupo do setor.', NULL, @pedro, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @pedro, @lucas, '2026-06-12 08:35:00', 3, 3, 2, 2, 3, 2, 3, 3, 'Faltou dar retorno durante o atendimento.');
-- 4º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Instalar programa de PDF', 'Preciso de um editor de PDF instalado.', 'Requisição de serviço', 'Software / Sistema', 'Baixo', 'Baixa', 'P4', 'Concluído', 72,
        '2026-07-10 13:00:00', '2026-07-14 10:35:00', '2026-07-14 10:35:00', 'Programa instalado e licenciado.', NULL, @pedro, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @pedro, @rafael, '2026-07-14 17:35:00', 2, 2, 3, 3, 3, 1, 4, 4, NULL);
-- 5º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Notebook superaquecendo', 'O notebook esquenta muito e desliga sozinho.', 'Incidente', 'Hardware', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-09-24 10:30:00', '2026-09-25 08:30:00', '2026-09-25 08:30:00', 'Limpeza interna e troca da pasta térmica.', NULL, @pedro, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @pedro, @patricia, '2026-09-28 14:30:00', 3, 2, 3, 3, 3, 4, 3, 4, 'Técnico muito atencioso.');
-- 6º chamado - Em análise
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Telefone IP sem linha', 'O telefone da mesa está sem sinal de linha.', 'Incidente', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Em análise', 24,
        '2026-11-23 13:40:00', '2026-11-23 16:40:00', NULL, NULL, NULL, @pedro, @lucas);

-- ===== FERNANDA LIMA (6 chamados) =====
-- 1º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Excel travando', 'O Excel trava ao abrir planilhas grandes.', 'Incidente', 'Software / Sistema', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2025-12-08 15:40:00', '2025-12-10 17:40:00', '2025-12-10 17:40:00', 'Office reparado e suplementos desativados.', NULL, @fernanda, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @fernanda, @rafael, '2025-12-11 09:40:00', 1, 2, 2, 3, 3, 1, 2, 1, 'O problema voltou alguns dias depois.');
-- 2º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Mouse sem fio parou', 'O mouse sem fio não responde mesmo trocando a pilha.', 'Incidente', 'Impressora / Periféricos', 'Baixo', 'Baixa', 'P4', 'Concluído', 72,
        '2025-12-15 09:40:00', '2025-12-17 09:35:00', '2025-12-17 09:35:00', 'Receptor USB substituído.', NULL, @fernanda, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @fernanda, @patricia, '2025-12-18 08:20:00', 3, 4, 2, 2, 2, 4, 3, 2, NULL);
-- 3º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Wi-Fi da sala de reunião caindo', 'A rede sem fio cai durante as reuniões.', 'Incidente', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-02-02 08:50:00', '2026-02-03 10:20:00', '2026-02-03 10:20:00', 'Access point reconfigurado em outro canal.', NULL, @fernanda, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @fernanda, @lucas, '2026-02-04 10:20:00', 1, 2, 2, 3, 1, 2, 2, 2, NULL);
-- 4º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Backup de arquivos', 'Preciso recuperar uma planilha apagada ontem.', 'Requisição de serviço', 'Software / Sistema', 'Médio', 'Alta', 'P2', 'Concluído', 8,
        '2026-04-03 10:15:00', '2026-04-03 13:15:00', '2026-04-03 13:15:00', 'Arquivo restaurado do backup.', NULL, @fernanda, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @fernanda, @rafael, '2026-04-06 10:35:00', 3, 1, 1, 2, 3, 2, 2, 3, 'Faltou dar retorno durante o atendimento.');
-- 5º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Telefone IP sem linha', 'O telefone da mesa está sem sinal de linha.', 'Incidente', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-08-03 10:50:00', '2026-08-04 08:20:00', '2026-08-04 08:20:00', 'Ramal reconfigurado na central.', NULL, @fernanda, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @fernanda, @lucas, '2026-08-05 10:50:00', 2, 2, 1, 1, 3, 2, 1, 2, 'Demorou mais do que eu esperava.');
-- 6º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Dúvida sobre assinatura de e-mail', 'Como configuro a assinatura padrão da empresa?', 'Requisição de serviço', 'Solicitação / Dúvida', 'Baixo', 'Baixa', 'P4', 'Concluído', 72,
        '2026-10-21 10:40:00', '2026-10-26 16:40:00', '2026-10-26 16:40:00', 'Orientação enviada com passo a passo.', NULL, @fernanda, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @fernanda, @rafael, '2026-10-27 09:40:00', 2, 2, 3, 3, 2, 1, 2, 3, 'Faltou dar retorno durante o atendimento.');

-- ===== RICARDO ALVES (4 chamados) =====
-- 1º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Senha do e-mail bloqueada', 'Errei a senha e a conta de e-mail foi bloqueada.', 'Requisição de serviço', 'Rede / Acesso', 'Baixo', 'Alta', 'P3', 'Concluído', 24,
        '2026-02-23 11:50:00', '2026-02-24 10:50:00', '2026-02-24 10:50:00', 'Senha redefinida e conta desbloqueada.', NULL, @ricardo, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @ricardo, @lucas, '2026-02-24 13:50:00', 3, 3, 3, 4, 3, 4, 4, 3, 'Explicou tudo com clareza.');
-- 2º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Teclado com teclas falhando', 'Algumas teclas não funcionam (A, S e Enter).', 'Incidente', 'Impressora / Periféricos', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2026-03-09 11:20:00', '2026-03-13 09:20:00', '2026-03-13 09:20:00', 'Teclado substituído por um novo.', NULL, @ricardo, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @ricardo, @patricia, '2026-03-16 11:20:00', 4, 3, 2, 4, 4, 3, 3, 3, NULL);
-- 3º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Dúvida sobre assinatura de e-mail', 'Como configuro a assinatura padrão da empresa?', 'Requisição de serviço', 'Solicitação / Dúvida', 'Baixo', 'Baixa', 'P4', 'Concluído', 72,
        '2026-03-30 12:30:00', '2026-03-31 10:30:00', '2026-03-31 10:30:00', 'Orientação enviada com passo a passo.', NULL, @ricardo, @rafael);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @ricardo, @rafael, '2026-04-01 10:05:00', 2, 3, 4, 3, 4, 4, 2, 3, 'Explicou tudo com clareza.');
-- 4º chamado - Aberto
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Liberar acesso ao sistema de vendas', 'Novo colaborador precisa de acesso ao sistema.', 'Requisição de serviço', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Aberto', 24,
        '2026-11-19 16:40:00', NULL, NULL, NULL, NULL, @ricardo, NULL);

-- ===== CAMILA ROCHA (5 chamados) =====
-- 1º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Wi-Fi da sala de reunião caindo', 'A rede sem fio cai durante as reuniões.', 'Incidente', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-01-15 12:30:00', '2026-01-16 08:05:00', '2026-01-16 08:05:00', 'Access point reconfigurado em outro canal.', NULL, @camila, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @camila, @lucas, '2026-01-19 13:05:00', 3, 3, 4, 4, 4, 2, 3, 3, 'Técnico muito atencioso.');
-- 2º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Teclado com teclas falhando', 'Algumas teclas não funcionam (A, S e Enter).', 'Incidente', 'Impressora / Periféricos', 'Baixo', 'Média', 'P4', 'Concluído', 72,
        '2026-08-24 13:15:00', '2026-08-26 08:20:00', '2026-08-26 08:20:00', 'Teclado substituído por um novo.', NULL, @camila, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @camila, @patricia, '2026-08-27 08:35:00', 3, 4, 4, 3, 4, 4, 4, 4, 'Resolveu de primeira.');
-- 3º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Como usar a nova impressora', 'Não sei escanear para o e-mail na impressora nova.', 'Requisição de serviço', 'Solicitação / Dúvida', 'Baixo', 'Baixa', 'P4', 'Concluído', 72,
        '2026-08-24 15:20:00', '2026-08-28 09:20:00', '2026-08-28 09:20:00', 'Usuário orientado presencialmente.', NULL, @camila, @patricia);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @camila, @patricia, '2026-08-31 09:05:00', 2, 3, 3, 4, 3, 3, 4, 3, 'Muito bom, obrigado!');
-- 4º chamado - Concluído
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Liberar acesso ao sistema de vendas', 'Novo colaborador precisa de acesso ao sistema.', 'Requisição de serviço', 'Rede / Acesso', 'Médio', 'Média', 'P3', 'Concluído', 24,
        '2026-09-01 15:20:00', '2026-09-02 12:20:00', '2026-09-02 12:20:00', 'Usuário criado no sistema de vendas.', NULL, @camila, @lucas);
INSERT INTO pesquisa (id_chamado, id_usuario, id_tecnico, data_resposta, q1, q2, q3, q4, q5, q6, q7, q8, observacao)
VALUES (LAST_INSERT_ID(), @camila, @lucas, '2026-09-03 08:05:00', 4, 3, 4, 3, 4, 2, 3, 3, NULL);
-- 5º chamado - Concluído (pesquisa AINDA NÃO respondida)
INSERT INTO chamados (titulo, descricao, tipo, categoria, impacto, urgencia, prioridade, status, sla_horas,
                      data_abertura, data_atualizacao, data_conclusao, solucao_resumo, observacao, id_usuario, id_tecnico)
VALUES ('Instalar programa de PDF', 'Preciso de um editor de PDF instalado.', 'Requisição de serviço', 'Software / Sistema', 'Baixo', 'Baixa', 'P4', 'Concluído', 72,
        '2026-11-20 13:20:00', '2026-11-23 08:05:00', '2026-11-23 08:05:00', 'Programa instalado e licenciado.', NULL, @camila, @rafael);

