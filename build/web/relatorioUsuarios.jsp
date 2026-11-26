<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="DAO.PesquisaDAO"%>
<%@page import="model.PesquisaBean"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }
    if (!usuario.isTI()) { response.sendRedirect("painel.jsp"); return; }

    String tituloPagina = "Relatório de respostas";
    List<PesquisaBean> lista = new ArrayList<PesquisaBean>();
    String erroPagina = null;
    try {
        lista = new PesquisaDAO().relatorioPorUsuario();
    } catch (Exception e) {
        erroPagina = "Não foi possível gerar o relatório. Verifique a conexão com o banco.";
    }
%>
<%@ include file="includes/topo.jspf" %>

<h2>Relatório 1: respostas por entrevistado</h2>
<p class="ajuda">Cada linha é uma pesquisa respondida. As respostas são 1, 2, 3 ou 4 (veja as alternativas na tela da pesquisa).</p>

<% if (erroPagina != null) { %><p class="msg erro"><%= erroPagina %></p><% } %>

<table>
    <thead>
        <tr>
            <th>Entrevistado</th>
            <th>Chamado</th>
            <% for (int q = 1; q <= 8; q++) { %><th>Q<%= q %></th><% } %>
            <th>Data da resposta</th>
        </tr>
    </thead>
    <tbody>
    <% if (lista.isEmpty() && erroPagina == null) { %>
        <tr><td colspan="11">Nenhuma pesquisa respondida ainda.</td></tr>
    <% } %>
    <% for (PesquisaBean p : lista) {
           int[] r = {p.getQ1(), p.getQ2(), p.getQ3(), p.getQ4(),
                      p.getQ5(), p.getQ6(), p.getQ7(), p.getQ8()}; %>
        <tr>
            <td><%= Texto.escapar(p.getNomeUsuario()) %></td>
            <td><%= Texto.escapar(p.getTituloChamado()) %></td>
            <% for (int valor : r) { %><td><%= valor %></td><% } %>
            <td><%= Texto.formatarData(p.getDataResposta()) %></td>
        </tr>
    <% } %>
    </tbody>
</table>

<%@ include file="includes/rodape.jspf" %>
