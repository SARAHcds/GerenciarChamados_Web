<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="DAO.ChamadoDAO"%>
<%@page import="DAO.PesquisaDAO"%>
<%@page import="model.ChamadoBean"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }

    String tituloPagina = "Painel";
    String filtro = request.getParameter("filtro");
    if (filtro == null) { filtro = "abertos"; }

    List<ChamadoBean> lista = new ArrayList<ChamadoBean>();
    Set<Integer> respondidos = new HashSet<Integer>();
    String erroPagina = null;
    try {
        ChamadoDAO dao = new ChamadoDAO();
        if (!usuario.isTI()) {
            lista = dao.listarDoSolicitante(usuario.getIdUsuario());
            PesquisaDAO pdao = new PesquisaDAO();
            for (ChamadoBean c : lista) {
                if (ChamadoBean.STATUS_CONCLUIDO.equals(c.getStatus()) && pdao.jaRespondida(c.getIdChamado())) {
                    respondidos.add(c.getIdChamado());
                }
            }
        } else if ("semresp".equals(filtro)) {
            lista = dao.listarSemResponsavel();
        } else if ("meus".equals(filtro)) {
            lista = dao.listarDoTecnico(usuario.getIdUsuario());
        } else {
            lista = dao.listarAbertos();
        }
    } catch (Exception e) {
        erroPagina = "Não foi possível carregar os chamados. Verifique a conexão com o banco.";
    }
%>
<%@ include file="includes/topo.jspf" %>

<h2><%= usuario.isTI() ? "Chamados" : "Meus chamados" %></h2>

<% if (usuario.isTI()) { %>
<div class="abas">
    <a href="painel.jsp?filtro=abertos" class="<%= "abertos".equals(filtro) ? "ativa" : "" %>">Todos os abertos</a>
    <a href="painel.jsp?filtro=semresp" class="<%= "semresp".equals(filtro) ? "ativa" : "" %>">Sem responsável</a>
    <a href="painel.jsp?filtro=meus" class="<%= "meus".equals(filtro) ? "ativa" : "" %>">Meus chamados</a>
</div>
<% } else { %>
<a href="novoChamado.jsp" class="botao">Novo chamado</a>
<% } %>

<% if (erroPagina != null) { %>
    <p class="msg erro"><%= erroPagina %></p>
<% } %>

<table>
    <thead>
        <tr>
            <th>Nº</th>
            <th>Título</th>
            <th>Categoria</th>
            <th>Prioridade</th>
            <th>Status</th>
            <th>Abertura</th>
            <th>Técnico</th>
            <th>Ações</th>
        </tr>
    </thead>
    <tbody>
    <% if (lista.isEmpty() && erroPagina == null) { %>
        <tr><td colspan="8">Nenhum chamado encontrado.</td></tr>
    <% } %>
    <% for (ChamadoBean c : lista) { %>
        <tr>
            <td><%= c.getIdChamado() %></td>
            <td><%= Texto.escapar(c.getTitulo()) %></td>
            <td><%= c.getCategoria() %></td>
            <td><%= c.getPrioridade() %> (SLA <%= c.getSlaHoras() %>h)</td>
            <td><%= c.getStatus() %></td>
            <td><%= Texto.formatarData(c.getDataAbertura()) %></td>
            <td><%= c.getNomeTecnico() == null ? "—" : Texto.escapar(c.getNomeTecnico()) %></td>
            <td>
                <a href="chamado.jsp?id=<%= c.getIdChamado() %>">Ver</a>
                <% if (!usuario.isTI() && ChamadoBean.STATUS_CONCLUIDO.equals(c.getStatus())
                        && !respondidos.contains(c.getIdChamado())) { %>
                    | <a href="pesquisa.jsp?id=<%= c.getIdChamado() %>" class="botao">Responder pesquisa</a>
                <% } %>
            </td>
        </tr>
    <% } %>
    </tbody>
</table>

<%@ include file="includes/rodape.jspf" %>
