<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="DAO.ChamadoDAO"%>
<%@page import="model.ChamadoBean"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }

    String tituloPagina = "Chamado";
    String erroPagina = null;
    ChamadoBean c = null;
    try {
        int id = Integer.parseInt(request.getParameter("id"));
        c = new ChamadoDAO().buscarPorId(id);
        if (c == null) {
            erroPagina = "Chamado não encontrado.";
        } else if (!usuario.isTI() && c.getIdUsuario() != usuario.getIdUsuario()) {
            c = null;
            erroPagina = "Você não tem acesso a este chamado.";
        }
    } catch (Exception e) {
        erroPagina = "Chamado não encontrado.";
    }

    boolean ehDono = c != null && c.getIdUsuario() == usuario.getIdUsuario();
    boolean ehResponsavel = c != null && usuario.isTI() && c.getIdTecnico() == usuario.getIdUsuario();
    boolean aberto = c != null && ChamadoBean.STATUS_ABERTO.equals(c.getStatus());
    boolean emAndamento = c != null && ChamadoBean.STATUS_EM_ANDAMENTO.equals(c.getStatus());
    boolean concluido = c != null && ChamadoBean.STATUS_CONCLUIDO.equals(c.getStatus());
    String[] statusOpcoes = {ChamadoBean.STATUS_EM_ANALISE, ChamadoBean.STATUS_EM_ANDAMENTO,
                             ChamadoBean.STATUS_AGUARDANDO};
%>
<%@ include file="includes/topo.jspf" %>

<% if (c == null) { %>
    <p class="msg erro"><%= erroPagina %></p>
    <a href="painel.jsp">Voltar ao painel</a>
<% } else { %>

<h2>Chamado nº <%= c.getIdChamado() %> - <%= Texto.escapar(c.getTitulo()) %></h2>

<dl class="detalhes">
    <dt>Status</dt><dd><%= c.getStatus() %></dd>
    <dt>Tipo</dt><dd><%= c.getTipo() %></dd>
    <dt>Categoria</dt><dd><%= c.getCategoria() %></dd>
    <dt>Impacto / Urgência</dt><dd><%= c.getImpacto() %> / <%= c.getUrgencia() %></dd>
    <dt>Prioridade</dt><dd><%= c.getPrioridade() %> (SLA de <%= c.getSlaHoras() %> horas)</dd>
    <dt>Solicitante</dt><dd><%= Texto.escapar(c.getNomeSolicitante()) %></dd>
    <dt>Técnico responsável</dt><dd><%= c.getNomeTecnico() == null ? "Ainda sem responsável" : Texto.escapar(c.getNomeTecnico()) %></dd>
    <dt>Abertura</dt><dd><%= Texto.formatarData(c.getDataAbertura()) %></dd>
    <dt>Última atualização</dt><dd><%= Texto.formatarData(c.getDataAtualizacao()) %></dd>
    <dt>Conclusão</dt><dd><%= Texto.formatarData(c.getDataConclusao()) %></dd>
    <dt>Descrição</dt><dd><%= Texto.escapar(c.getDescricao()) %></dd>
    <% if (c.getSolucaoResumo() != null) { %>
        <dt>Solução</dt><dd><%= Texto.escapar(c.getSolucaoResumo()) %></dd>
    <% } %>
</dl>

<section class="acoes">
    <% if ((ehDono || usuario.isTI()) && !concluido) { %>
        <a href="editarChamado.jsp?id=<%= c.getIdChamado() %>" class="botao">Editar chamado</a>
    <% } %>

    <% if (usuario.isTI() && aberto && c.getIdTecnico() == 0) { %>
        <form method="post" action="chamadoAcao.jsp">
            <input type="hidden" name="acao" value="assumir">
            <input type="hidden" name="id" value="<%= c.getIdChamado() %>">
            <button type="submit" class="botao">Assumir chamado</button>
        </form>
    <% } %>

    <% if (ehResponsavel && !aberto && !emAndamento && !concluido) { %>
        <form method="post" action="chamadoAcao.jsp">
            <input type="hidden" name="acao" value="status">
            <input type="hidden" name="id" value="<%= c.getIdChamado() %>">
            <select name="novoStatus">
                <% for (String s : statusOpcoes) {
                       if (ChamadoBean.transicaoPermitida(c.getStatus(), s)) { %>
                    <option value="<%= s %>"><%= s %></option>
                <% } } %>
            </select>
            <button type="submit" class="botao">Alterar status</button>
        </form>
    <% } %>

    <% if (ehResponsavel && emAndamento) { %>
        <form method="post" action="chamadoAcao.jsp">
            <input type="hidden" name="acao" value="status">
            <input type="hidden" name="id" value="<%= c.getIdChamado() %>">
            <input type="hidden" name="novoStatus" value="<%= ChamadoBean.STATUS_AGUARDANDO %>">
            <button type="submit" class="botao">Aguardar resposta do usuário</button>
        </form>
        <form method="post" action="chamadoAcao.jsp">
            <input type="hidden" name="acao" value="concluir">
            <input type="hidden" name="id" value="<%= c.getIdChamado() %>">
            <label>Resumo da solução (obrigatório)
                <textarea name="solucao" required></textarea>
            </label>
            <button type="submit" class="botao">Concluir chamado</button>
        </form>
    <% } %>

    <% if (usuario.isTI() && aberto) { %>
        <form method="post" action="chamadoAcao.jsp" onsubmit="return confirm('Excluir este chamado?');">
            <input type="hidden" name="acao" value="excluir">
            <input type="hidden" name="id" value="<%= c.getIdChamado() %>">
            <button type="submit" class="botao perigo">Excluir chamado</button>
        </form>
    <% } %>
</section>

<p><a href="painel.jsp">Voltar ao painel</a></p>
<% } %>

<%@ include file="includes/rodape.jspf" %>
