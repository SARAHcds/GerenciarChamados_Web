<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="DAO.PesquisaDAO"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.PerguntasPesquisa"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }
    if (!usuario.isTI()) { response.sendRedirect("painel.jsp"); return; }

    String tituloPagina = "Relatório de resumo";
    int total = 0;
    List<double[]> percentuais = new ArrayList<double[]>();
    String erroPagina = null;
    try {
        PesquisaDAO dao = new PesquisaDAO();
        total = dao.totalEntrevistados();
        for (int q = 1; q <= PerguntasPesquisa.PERGUNTAS.length; q++) {
            percentuais.add(dao.percentuaisDaQuestao(q));
        }
    } catch (Exception e) {
        erroPagina = "Não foi possível gerar o resumo. Verifique a conexão com o banco.";
    }
%>
<%@ include file="includes/topo.jspf" %>

<h2>Relatório 2: resumo estatístico</h2>

<% if (erroPagina != null) { %>
    <p class="msg erro"><%= erroPagina %></p>
<% } else { %>

<p><strong>Número de entrevistados:</strong> <%= total %></p>

<% if (total == 0) { %>
    <p class="msg erro">Ainda não há pesquisas respondidas.</p>
<% } else { %>

<% for (int q = 0; q < percentuais.size(); q++) {
       double[] pct = percentuais.get(q); %>
    <h3>Questão <%= q + 1 %>: <%= PerguntasPesquisa.PERGUNTAS[q] %></h3>
    <table>
        <thead>
            <tr><th>Alternativa</th><th>Percentual</th><th>Gráfico</th></tr>
        </thead>
        <tbody>
        <% for (int op = 0; op < 4; op++) { %>
            <tr>
                <td><%= (op + 1) %> - <%= PerguntasPesquisa.OPCOES[op] %></td>
                <td><%= String.format("%.1f%%", pct[op]) %></td>
                <td>
                    <div class="barra-fundo">
                        <div class="barra" style="width: <%= String.format(Locale.US, "%.1f", pct[op]) %>%"></div>
                    </div>
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>
<% } %>

<% } %>
<% } %>

<%@ include file="includes/rodape.jspf" %>
