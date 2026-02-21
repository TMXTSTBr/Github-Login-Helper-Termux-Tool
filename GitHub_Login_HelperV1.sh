#!/bin/bash
# Github Login Helper - Termux
# Autor: YTDroidX
# Profissional, bilíngue (PT/EN) e ASCII Art no nome

# ================= Cores =================
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
WHITE="\033[97m"
RESET="\033[0m"

# ================= Figlet =================
if ! command -v figlet &> /dev/null; then
    echo -e "${YELLOW}[!] figlet não encontrado. Instalando...${RESET}"
    pkg update -y
    pkg install figlet -y
fi

# ================= ASCII Art =================
clear
figlet -f slant "Github Login Helper"
echo -e "${CYAN}Author: YTDroidX${RESET}\n"

# ================= Idioma =================
LANGUAGE="pt"  # alterar para "en" para inglês

# ================= Menu =================
show_menu() {
    echo -e "${CYAN}==============================${RESET}"
    echo -e "${GREEN}Menu Principal${RESET}"
    echo -e "${CYAN}==============================${RESET}"
    if [ "$LANGUAGE" == "pt" ]; then
        echo -e "${WHITE}1) Configurar usuário e e-mail${RESET}"
        echo -e "${WHITE}2) Configurar token de acesso${RESET}"
        echo -e "${WHITE}3) Testar login com repositório${RESET}"
        echo -e "${WHITE}4) Configurar SSH key${RESET}"
        echo -e "${WHITE}5) Sair${RESET}"
    else
        echo -e "${WHITE}1) Set username and email${RESET}"
        echo -e "${WHITE}2) Set access token${RESET}"
        echo -e "${WHITE}3) Test login with repository${RESET}"
        echo -e "${WHITE}4) Setup SSH key${RESET}"
        echo -e "${WHITE}5) Exit${RESET}"
    fi
    echo -n -e "${BLUE}Escolha uma opção: ${RESET}"
}

# ================= Função Principal =================
while true; do
    show_menu
    read choice
    case $choice in
        # ---------------- Opção 1 ----------------
        1)
            read -p "Digite seu nome de usuário do GitHub: " github_user
            read -p "Digite seu e-mail do GitHub: " github_email

            current_user=$(git config --global user.name)
            current_email=$(git config --global user.email)
            changed=false

            [ ! -z "$github_user" ] && git config --global user.name "$github_user" && changed=true
            [ ! -z "$github_email" ] && git config --global user.email "$github_email" && changed=true

            if [ "$changed" = true ]; then
                echo -e "\n${GREEN}✅ Configuração concluída com sucesso!${RESET}"
            elif [ ! -z "$current_user" ] || [ ! -z "$current_email" ]; then
                echo -e "\n${YELLOW}⚠️ Nenhuma alteração feita. Mantendo valores existentes.${RESET}"
            else
                echo -e "\n${RED}❌ Nenhum dado configurado.${RESET}"
            fi

            echo -e "${CYAN}Usuário: ${WHITE}$(git config --global user.name)${RESET}"
            echo -e "${CYAN}E-mail: ${WHITE}$(git config --global user.email)${RESET}\n"
            read -n 1 -s -r -p "Pressione qualquer tecla para voltar ao menu..."
            clear
            ;;
        # ---------------- Opção 2 ----------------
        2)
            echo -e "\n⚠️ Use um Personal Access Token (PAT)."
            echo "Veja: https://github.com/settings/tokens"
            read -p "Digite seu token: " github_token

            changed=false
            if [ ! -z "$github_token" ]; then
                git config --global credential.helper store
                echo "https://$github_token:@github.com" > ~/.git-credentials
                changed=true
            fi

            if [ "$changed" = true ]; then
                echo -e "\n${GREEN}✅ Token armazenado com sucesso!${RESET}"
            elif [ -f ~/.git-credentials ]; then
                echo -e "\n${YELLOW}⚠️ Nenhuma alteração feita. Mantendo token existente.${RESET}"
            else
                echo -e "\n${RED}❌ Nenhum token configurado.${RESET}"
            fi

            read -n 1 -s -r -p "Pressione qualquer tecla para voltar ao menu..."
            clear
            ;;
        # ---------------- Opção 3 ----------------
        3)
            read -p "Digite um repositório público para teste (user/repo) ou ENTER para pular: " test_repo
            if [ ! -z "$test_repo" ]; then
                git clone https://$github_user:$github_token@github.com/$test_repo.git
                echo -e "${GREEN}[+] Teste concluído!${RESET}"
            else
                echo -e "${YELLOW}[!] Teste ignorado.${RESET}"
            fi
            read -n 1 -s -r -p "Pressione qualquer tecla para voltar ao menu..."
            clear
            ;;
        # ---------------- Opção 4 ----------------
        4)
            echo -e "\n🔑 Configuração de SSH para GitHub"

            # Checa se já existe chave
            if [ -f ~/.ssh/id_ed25519.pub ]; then
                echo -e "${YELLOW}⚠️ Já existe uma chave SSH: ~/.ssh/id_ed25519.pub${RESET}"
                read -p "Deseja gerar uma nova chave? (s/n): " gen_new
                if [[ ! "$gen_new" =~ ^[sS]$ ]]; then
                    echo -e "${CYAN}✅ Mantendo chave existente.${RESET}"
                    read -n 1 -s -r -p "Pressione qualquer tecla para voltar ao menu..."
                    clear
                    continue
                fi
            fi

            read -p "Digite seu e-mail do GitHub para a chave SSH: " github_email_ssh
            ssh-keygen -t ed25519 -C "$github_email_ssh" -f ~/.ssh/id_ed25519 -N ""
            eval "$(ssh-agent -s)"
            ssh-add ~/.ssh/id_ed25519

            echo -e "\n${GREEN}✅ Chave SSH criada com sucesso!${RESET}"
            echo -e "${CYAN}Chave pública:\n${WHITE}$(cat ~/.ssh/id_ed25519.pub)${RESET}"
            echo -e "${YELLOW}Copie essa chave para: https://github.com/settings/keys${RESET}"
            read -n 1 -s -r -p "Pressione qualquer tecla para voltar ao menu..."
            clear
            ;;
        # ---------------- Opção 5 ----------------
        5)
            echo -e "${CYAN}Saindo...${RESET}"
            exit 0
            ;;
        # ---------------- Opção inválida ----------------
        *)
            echo -e "${RED}[!] Opção inválida!${RESET}"
            read -n 1 -s -r -p "Pressione qualquer tecla para voltar ao menu..."
            clear
            ;;
    esac
done
