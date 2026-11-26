package model;

import java.util.Date;

/*
Armazena os dados do usuário (solicitante ou equipe de TI).
*/
public class UsuarioBean {

    public static final String PERFIL_TI = "TI";
    public static final String PERFIL_SOLICITANTE = "SOLICITANTE";

    private int idUsuario;
    private String nome;
    private String email;
    private String senha;
    private String perfil;
    private String matricula;
    private String setor;
    private String cargo;
    private String telefone;
    private String especialidade;
    private boolean ativo;
    private Date dataCadastro;
    private Date dataAtualizacao;
    private Date ultimoAcesso;

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }

    public String getPerfil() { return perfil; }
    public void setPerfil(String perfil) { this.perfil = perfil; }

    public String getMatricula() { return matricula; }
    public void setMatricula(String matricula) { this.matricula = matricula; }

    public String getSetor() { return setor; }
    public void setSetor(String setor) { this.setor = setor; }

    public String getCargo() { return cargo; }
    public void setCargo(String cargo) { this.cargo = cargo; }

    public String getTelefone() { return telefone; }
    public void setTelefone(String telefone) { this.telefone = telefone; }

    public String getEspecialidade() { return especialidade; }
    public void setEspecialidade(String especialidade) { this.especialidade = especialidade; }

    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }

    public Date getDataCadastro() { return dataCadastro; }
    public void setDataCadastro(Date dataCadastro) { this.dataCadastro = dataCadastro; }

    public Date getDataAtualizacao() { return dataAtualizacao; }
    public void setDataAtualizacao(Date dataAtualizacao) { this.dataAtualizacao = dataAtualizacao; }

    public Date getUltimoAcesso() { return ultimoAcesso; }
    public void setUltimoAcesso(Date ultimoAcesso) { this.ultimoAcesso = ultimoAcesso; }

    // A equipe de TI enxerga os chamados de todos e pode excluir chamados abertos.
    public boolean isTI() { return PERFIL_TI.equals(perfil); }
}
