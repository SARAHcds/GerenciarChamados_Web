<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="DAO.UsuarioDAO"%>
<%@page import="model.UsuarioBean"%>
<%
    String email = request.getParameter("email");
    String senha = request.getParameter("senha");
    UsuarioBean usuario = null;
    boolean erroBanco = false;
    try {
        usuario = new UsuarioDAO().autenticar(email, senha);
    } catch (Exception e) {
        erroBanco = true;
    }
    if (usuario != null) {
        session.setAttribute("usuario", usuario);
        response.sendRedirect("painel.jsp");
        return;
    }
    response.sendRedirect(erroBanco ? "login.jsp?erro=2" : "login.jsp?erro=1");
%>
