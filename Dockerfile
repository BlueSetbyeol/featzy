FROM node

RUN apt-get update && \
    apt-get upgrade -y && \
	apt-get install -y git

WORKDIR /poketmonster_sap

RUN git clone --branch docker_change https://github.com/BlueSetbyeol/pokemonster_sap.git /poketmonster_sap

RUN npm i

EXPOSE 3000

CMD ["npm", "run", "dev"]