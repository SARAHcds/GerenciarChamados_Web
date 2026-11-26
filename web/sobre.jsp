<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.UsuarioBean"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestão de Chamados de TI - Gerenciar Chamados</title>
    <link rel="stylesheet" href="css/estilo.css">
    <link rel="stylesheet" href="css/tema.css">
</head>
<body class="publico">

<header class="topo">
    <span class="marca">Gerenciar Chamados</span>
    <nav>
        <a href="sobre.jsp">Início</a>
        <% if (usuario != null) { %>
            <a href="painel.jsp">Meu painel</a>
        <% } else { %>
            <a href="login.jsp" class="botao">Entrar</a>
        <% } %>
    </nav>
</header>

<!-- Apresentação -->
<section class="hero">
    <div>
        <p class="rotulo">Gestão de chamados de TI</p>
        <h1>Um chamado bem registrado é o primeiro passo para resolver qualquer problema.</h1>
        <p>Veja como os chamados são classificados, priorizados e acompanhados até a conclusão,
           com base em boas práticas do ITIL 4.</p>
        <% if (usuario == null) { %>
            <a href="login.jsp" class="botao">Entrar e abrir um chamado</a>
        <% } %>
    </div>
    <div>
        <svg class="hero-svg" viewBox="0 0 420 320" xmlns="http://www.w3.org/2000/svg" role="img"
             aria-label="Ilustração de um chamado concluído com sucesso">
            <rect x="50" y="30" width="320" height="230" rx="18" fill="#ffffff" opacity="0.15"/>
            <rect x="75" y="55" width="270" height="180" rx="10" fill="#ffffff"/>
            <rect x="100" y="82" width="160" height="12" rx="6" fill="#1f5fa8" opacity="0.7"/>
            <rect x="100" y="106" width="210" height="9" rx="4" fill="#c5ccd6"/>
            <rect x="100" y="124" width="180" height="9" rx="4" fill="#c5ccd6"/>
            <rect x="100" y="150" width="110" height="28" rx="14" fill="#27ae60"/>
            <text x="155" y="169" font-size="13" font-family="Arial" font-weight="bold" fill="#ffffff" text-anchor="middle">Concluído</text>
            <circle cx="338" cy="66" r="28" fill="#27ae60"/>
            <path d="M324 66 l10 10 l18 -20" stroke="#ffffff" stroke-width="5" fill="none"
                  stroke-linecap="round" stroke-linejoin="round"/>
            <rect x="130" y="262" width="160" height="12" rx="6" fill="#ffffff" opacity="0.3"/>
            <rect x="105" y="280" width="210" height="12" rx="6" fill="#ffffff" opacity="0.18"/>
        </svg>
    </div>
</section>

<!-- Tipos de chamado -->
<section class="secao">
    <h2>O que é um chamado</h2>
    <p>Todo chamado registra uma necessidade do usuário. No ITIL 4, ele se divide em dois tipos principais.</p>
    <div class="grade">
        <article class="card" style="--d: 0.05s">
            <svg class="icone" viewBox="0 0 44 44" aria-hidden="true">
                <circle cx="22" cy="22" r="20" fill="#f1c40f"/>
                <path d="M22 11 v14 M22 31 v2" stroke="#222" stroke-width="4" stroke-linecap="round"/>
            </svg>
            <h3>Incidente</h3>
            <p>Uma interrupção não planejada ou uma queda na qualidade de um serviço.
               Exemplo: um computador que não liga.</p>
        </article>
        <article class="card" style="--d: 0.15s">
            <svg class="icone" viewBox="0 0 44 44" aria-hidden="true">
                <circle cx="22" cy="22" r="20" fill="#1f5fa8"/>
                <path d="M14 22 l6 6 l10 -12" stroke="#fff" stroke-width="4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <h3>Requisição de serviço</h3>
            <p>Um pedido de algo previsto, como acesso, instalação ou uma dúvida.
               Exemplo: instalar uma impressora nova.</p>
        </article>
    </div>
</section>

<!-- Ciclo de vida -->
<section class="secao">
    <h2>Ciclo de vida do chamado</h2>
    <p>Cada chamado passa por etapas claras. O solicitante acompanha o andamento e, ao final, avalia o atendimento.</p>
    <div class="fluxo">
        <span class="etapa" style="--d: 0s">Aberto</span>
        <span class="seta">›</span>
        <span class="etapa" style="--d: 0.4s">Em análise</span>
        <span class="seta">›</span>
        <span class="etapa" style="--d: 0.8s">Em andamento</span>
        <span class="seta">›</span>
        <span class="etapa" style="--d: 1.2s">Aguardando usuário</span>
        <span class="seta">›</span>
        <span class="etapa final" style="--d: 1.6s">Concluído</span>
    </div>
    <p class="etapa-desc">Quando o chamado é concluído, o solicitante responde uma pesquisa de satisfação com 8 perguntas.
       Chamados concluídos ficam registrados para os relatórios.</p>
</section>

<!-- Prioridade e SLA -->
<section class="secao">
    <h2>Prioridade e prazo de atendimento (SLA)</h2>
    <p><strong>Impacto</strong> mede quantas pessoas ou processos são afetados.
       <strong>Urgência</strong> mede quanto tempo o problema pode esperar.
       A combinação dos dois define a prioridade, e cada prioridade tem um prazo.</p>

    <div style="overflow-x: auto;">
        <table class="matriz">
            <thead>
                <tr>
                    <th>Impacto \ Urgência</th>
                    <th>Alta</th>
                    <th>Média</th>
                    <th>Baixa</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <th>Alto</th>
                    <td class="p1">P1</td>
                    <td class="p2">P2</td>
                    <td class="p3">P3</td>
                </tr>
                <tr>
                    <th>Médio</th>
                    <td class="p2">P2</td>
                    <td class="p3">P3</td>
                    <td class="p4">P4</td>
                </tr>
                <tr>
                    <th>Baixo</th>
                    <td class="p3">P3</td>
                    <td class="p4">P4</td>
                    <td class="p4">P4</td>
                </tr>
            </tbody>
        </table>
    </div>

    <h3 style="margin-top: 22px; color: #1f3b5a;">Prazos (SLA)</h3>
    <div class="grade">
        <div class="card" style="--d: 0.05s"><span class="badge p1">P1</span><p style="margin-top: 10px;">Prazo de <strong>4 horas</strong></p></div>
        <div class="card" style="--d: 0.12s"><span class="badge p2">P2</span><p style="margin-top: 10px;">Prazo de <strong>8 horas</strong></p></div>
        <div class="card" style="--d: 0.19s"><span class="badge p3">P3</span><p style="margin-top: 10px;">Prazo de <strong>24 horas</strong></p></div>
        <div class="card" style="--d: 0.26s"><span class="badge p4">P4</span><p style="margin-top: 10px;">Prazo de <strong>72 horas</strong></p></div>
    </div>
</section>

<!-- Categorias -->
<section class="secao">
    <h2>Categorias de atendimento</h2>
    <p>Cada chamado é classificado em uma das categorias abaixo, para que vá direto à equipe certa.</p>
    <span class="pilula">Hardware</span>
    <span class="pilula">Software / Sistema</span>
    <span class="pilula">Rede / Acesso</span>
    <span class="pilula">Impressora / Periféricos</span>
    <span class="pilula">Solicitação / Dúvida</span>
</section>

<!-- Princípios ITIL 4 -->
<section class="secao">
    <h2>Princípios do ITIL 4 aplicados a este sistema</h2>
    <div class="grade">
        <article class="card" style="--d: 0.05s"><h3>Foque no valor</h3><p>Cada ação deve gerar um resultado útil para quem pediu ajuda.</p></article>
        <article class="card" style="--d: 0.10s"><h3>Comece de onde você está</h3><p>Use o que já existe antes de criar algo do zero.</p></article>
        <article class="card" style="--d: 0.15s"><h3>Progrida com feedback</h3><p>Melhore em pequenos ciclos, ouvindo quem usa o serviço.</p></article>
        <article class="card" style="--d: 0.20s"><h3>Colabore e dê visibilidade</h3><p>Solicitante e técnico acompanham o mesmo registro.</p></article>
        <article class="card" style="--d: 0.25s"><h3>Pense de forma holística</h3><p>Pessoas, processos e tecnologia funcionam juntos.</p></article>
        <article class="card" style="--d: 0.30s"><h3>Mantenha simples e prático</h3><p>Um processo fácil de seguir é um processo que será seguido.</p></article>
        <article class="card" style="--d: 0.35s"><h3>Otimize e automatize</h3><p>Prioridade e prazo já são calculados automaticamente aqui.</p></article>
    </div>
</section>

<!-- Chamada para ação -->
<section class="secao">
    <h2>Participe</h2>
    <p>Já abriu um chamado? Ao concluir o atendimento, responda a pesquisa de satisfação.
       Sua opinião ajuda a equipe de TI a melhorar.</p>
    <% if (usuario == null) { %>
        <a href="login.jsp" class="botao">Entrar</a>
    <% } else { %>
        <a href="painel.jsp" class="botao">Ir para o meu painel</a>
    <% } %>
</section>

<p class="rodape-pagina">Gerenciar Chamados · Projeto acadêmico</p>

</body>
</html>
