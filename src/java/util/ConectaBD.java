package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


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
