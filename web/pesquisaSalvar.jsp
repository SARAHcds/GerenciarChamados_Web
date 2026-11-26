<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="DAO.PesquisaDAO"%>
<%@page import="model.PesquisaBean"%>
<%@page import="model.UsuarioBean"%>
<%@page import="util.Texto"%>
<%
    UsuarioBean usuario = (UsuarioBean) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }

    String tituloPagina = "Pesquisa de satisfação";
    String sucesso = null;
    String erro = null;
    try {
        PesquisaBean p = new PesquisaBean();
        p.setIdChamado(Integer.parseInt(request.getParameter("idChamado")));
        p.setIdUsuario(usuario.getIdUsuario());
        p.setQ1(Integer.parseInt(request.getParameter("q1")));
        p.setQ2(Integer.parseInt(request.getParameter("q2")));
        p.setQ3(Integer.parseInt(request.getParameter("q3")));
        p.setQ4(Integer.parseInt(request.getParameter("q4")));
        p.setQ5(Integer.parseInt(request.getParameter("q5")));
        p.setQ6(Integer.parseInt(request.getParameter("q6")));
        p.setQ7(Integer.parseInt(request.getParameter("q7")));
        p.setQ8(Integer.parseInt(request.getParameter("q8")));

        String obs = Texto.limpar(request.getParameter("observacao"));
        if (obs.length() > 255) {
            obs = obs.substring(0, 255);
        }
        p.setObservacao(obs.isEmpty() ? null : obs);

        if (new PesquisaDAO().inserir(p)) {
            sucesso = "Obrigado! Sua pesquisa foi registrada.";
        } else {
            erro = "Não foi possível registrar: o chamado não está concluído, não é seu ou já foi respondido.";
        }
    } catch (NumberFormatException e) {
        erro = "Responda todas as perguntas com 1, 2, 3 ou 4.";
    } catch (IllegalArgumentException e) {
        erro = e.getMessage();
    } catch (Exception e) {
        erro = "Erro ao salvar a pesquisa. Verifique a conexão com o banco.";
    }
%>
<%@ include file="includes/topo.jspf" %>

<% if (sucesso != null) { %><p class="msg sucesso"><%= sucesso %></p><% } %>
<% if (erro != null) { %><p class="msg erro"><%= erro %></p><% } %>
<a href="painel.jsp">Voltar ao painel</a>

<%@ include file="includes/rodape.jspf" %>
