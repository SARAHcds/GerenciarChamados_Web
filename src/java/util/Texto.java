package util;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;

/*
Funções de apoio para as páginas JSP:
escapar: evita que texto digitado pelo usuário vire HTML (proteção contra XSS).
*/
public class Texto {

    public static String escapar(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    public static String limpar(String s) {
        return s == null ? "" : s.trim();
    }

    public static String formatarData(Date data) {
        if (data == null) {
            return "—";
        }
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(data);
    }

    public static boolean valorValido(String[] opcoes, String valor) {
        return valor != null && Arrays.asList(opcoes).contains(valor);
    }
}
