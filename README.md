# Gerenciar Chamados Web

Sistema web de **abertura e acompanhamento de chamados de suporte de TI**, desenvolvido em Java (JSP) no Apache NetBeans com banco de dados MySQL, como projeto acadêmico.

O solicitante abre chamados e acompanha o atendimento. A equipe de TI assume, trata e conclui os chamados. Ao final, o solicitante responde uma pesquisa de satisfação, que alimenta os relatórios do sistema.

---

## Funcionalidades

### Cadastro / Consulta / Alteração / Exclusão (chamados)
| Operação | Onde | Regra |
|---|---|---|
| **Cadastro** | `novoChamado.jsp` → `chamadoSalvar.jsp` | Qualquer usuário logado abre um chamado |
| **Consulta** | `chamado.jsp` | Exibe todos os dados do chamado, solicitante e técnico |
| **Alteração** | `editarChamado.jsp` → `chamadoAcao.jsp` | Só o solicitante dono do chamado ou a equipe de TI; chamado concluído não pode ser editado |
| **Exclusão** | `chamadoAcao.jsp` | Só a equipe de TI, e só chamados com status **Aberto** (os concluídos ficam para os relatórios) |

### Funcionalidade que manipula os dados (regras de negócio, baseadas no ITIL 4)
- **Prioridade calculada automaticamente** pela matriz impacto × urgência:
  Alto/Alta = 3, Médio/Média = 2, Baixo/Baixa = 1 → soma 6 = **P1**, 5 = **P2**, 4 = **P3**, 3 ou 2 = **P4**.
- **SLA definido pela prioridade:** P1 = 4h, P2 = 8h, P3 = 24h, P4 = 72h.
- **Fluxo de status controlado:**
  `Aberto` → (técnico assume) → `Em análise` → `Em andamento` ⇄ `Aguardando usuário` → `Concluído`.
  Para concluir, é obrigatório informar a solução. `Concluído` é um status final.
- **Pesquisa de satisfação** com 8 perguntas (respostas de 1 a 4), uma por chamado concluído.

### Listagens de dados
1. **Painel de chamados** (`painel.jsp`): o solicitante vê os próprios chamados; a equipe de TI filtra por *Todos os abertos*, *Sem responsável* e *Meus chamados*.
2. **Relatório de respostas** (`relatorioUsuarios.jsp`): cada entrevistado, o chamado avaliado e as 8 respostas.
3. **Relatório resumo** (`relatorioResumo.jsp`): total de entrevistados e o percentual de cada alternativa em cada pergunta.

### Perfis de acesso
- **SOLICITANTE**: abre, consulta e edita os próprios chamados e responde a pesquisa.
- **TI**: vê todos os chamados, assume, muda o status, conclui, exclui e acessa os relatórios.

---

## Tecnologias

- **Java** (JSP) no **Apache NetBeans**
- **Apache Tomcat** como servidor de aplicação
- **MySQL 8** (scripts testados no phpMyAdmin)
- **JDBC** com MySQL Connector/J
- HTML e CSS

---

## Estrutura do projeto

```
GerenciarChamados_Web/
├── banco/
│   └── gerenciar_chamados_web.sql   # criação do banco, tabelas e dados de teste
├── src/java/
│   ├── model/      
│   ├── DAO/        
│   └── util/       
└── web/
    ├── *.jsp       
    ├── includes/   
    └── css/        
```

### Banco de dados
| Tabela | Descrição |
|---|---|
| `usuario` | Usuários do sistema (perfil `TI` ou `SOLICITANTE`) |
| `chamados` | Chamados, com prioridade, SLA, status, solicitante e técnico responsável |
| `pesquisa` | Respostas da pesquisa de satisfação (uma por chamado) |

---

## Diagrama de classes

![Diagrama de classes](docs/diagrama-classes.png)

