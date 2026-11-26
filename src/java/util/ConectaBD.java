package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/*
Único ponto de conexão com o banco gerenciar_chamados_web.
Não usa JOptionPane: em aplicação web a mensagem de erro é mostrada na própria página.
*/
public class ConectaBD {

    private static final String URL = "jdbc:mysql://localhost:3306/gerenciar_chamados_web"
            + "?useSSL=false&allowPublicKeyRetrieval=true"
            + "&serverTimezone=America/Sao_Paulo&characterEncoding=UTF-8";
    private static final String USUARIO = "root";
    private static final String SENHA = "1234"; 

    public static Connection conectar() throws ClassNotFoundException, SQLException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USUARIO, SENHA);
    }
}
