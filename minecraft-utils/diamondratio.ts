// Given a player's name, look up their UUID, open their player stats, and
// calculate the ratio of diamonds to stone mined.

const stats_dir : string = 'The-Wild/world/stats';

const fs      = require('fs');
const sprintf = require('sprintf-js').sprintf;
const request = require('request');

const username : string = process.argv[2];
if (username == null) {
    console.log("You must supply a username");
    process.exit(1);
}

request('https://api.mojang.com/users/profiles/minecraft/' + username, 
    function (error, response, body) {
        if (error) {
            console.log("ERROR: " + error);
            process.exit(1);
        }
        let account = JSON.parse(body);

        check_ratio(account);
});

function check_ratio (player) {
    let padded_uuid : string = require("add-dashes-to-uuid")(player.id);
    let stats_file : string  = stats_dir + '/' + padded_uuid + '.json';

    let stats_data = JSON.parse( fs.readFileSync(stats_file) );
    let stats = stats_data.stats;
    //console.log("Got stats:", stats_data);

    let diamond_mined : number = stats["minecraft:mined"]["minecraft:diamond_ore"];

    if (diamond_mined == 0) {
        console.log(player.name + " has not mined any diamond yet");
        process.exit;
    }

    let stone_mined : number = stats["minecraft:mined"]["minecraft:stone"];

    let ratio : number = sprintf('%.4f', diamond_mined / stone_mined);

    console.log(
        `${player.name} mined ${diamond_mined} dia of ${stone_mined} stone = ${ratio}`
    );
}

