Demande de badge
Bonjour,

Serait-il possible de fournir ou renouveler un badge au bénéfice de {{ author.fullname }},
qui interviendra au sein de l’incubateur sous contrat de type {{ author.employer }},
{% if author.end and author.end != "" %}
du {{ author.start | date: "%d/%m/%Y" }} au {{ author.end | date: "%d/%m/%Y" }} ?
{% else %}
à compter du {{ author.start | date: "%d/%m/%Y" }} ?
{% endif %}

Bonne journée,  
Le secrétariat de l'Incubateur
