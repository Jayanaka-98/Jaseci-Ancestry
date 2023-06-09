import {*} with "./graph.jac";

walker create_familytree {
    // creates a familytree from a json file
    has data_file = "family_tree.json";
    has famly_members = [];

    root {
        families = file.load_json(data_file)["families"];
        for family in families {
            spawn here ++> node::family_root(
                id = family["id"],
                family_name = family["family_name"]
            );
        }
        take-->node::family_root;
    }

    family_root {
        family_id = here.id;
        members = file.load_json(data_file)["members"];
        filtered_members = [];
        for member in members {
            if (member["family_id"] == family_id) {
                filtered_members.list::append(member);
            }
        }
        for member in filtered_members {
            family_member = spawn here +[member]+> node::person(
                id = member["uid"],
                family_id = member["family_id"],
                name = member["name"],
                date_of_birth = member["date_of_birth"],
                profession = member["profession"],
                gender = member["gender"],
                deceased = member["deceased"],
                parents = member["parents"],
                children = member["children"],
                spouse = member["spouse"],
                hobbies = member["hobbies"],
                skills = member["skills"],
                cars = member["cars"],
                blood_group = member["blood_group"]

            );
            famly_members.list::append(family_member);
        }
    }

    with exit {
        for member_1 in famly_members {
            for member_2 in famly_members {
                if (member_1.id  == member_2.id): continue;
                if (member_1.spouse == member_2.id and member_2.spouse == member_1.id) {
                    member_1 +[married]+> member_2;
                }
                if (member_1.id in member_2.children): member_1 +[child]+> member_2;
            }
        }
    }
}

walker find_coming_birthday {
    // returns the upcoming birthdays of the family
    has max_return = 5;
    has anchor birthday_order = [];

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (!here.deceased) {
            here::get_days_to_birthday;
            here::get_age;
            birthday_order.l::append([here.days_to_birthday, here.age, here.name]);
        }
    }
    with exit {
        birthday_order = std.sort_by_col(birthday_order, 0);
        birthday_order = birthday_order[0:max_return];
        std.out(birthday_order);
        report birthday_order;
        }
}

walker hobby_cluster {
    has Hobby_list = {};
    has member_hobbies = [];
    has recorded = 0;
    has prev_Hobby_list = [];
    root: take-->node::family_root;
    family_root: take-->node::person;
    
    person{
        
        member_hobbies = here.hobbies;
        for hobby in member_hobbies{
            recorded = 0;
            for hobby_key in Hobby_list.dict::keys {
                if (hobby == hobby_key) {
                    prev_Hobby_list = Hobby_list[hobby_key];
                    Hobby_list.dict::update({ hobby_key :  prev_Hobby_list + [here.id]});
                    //Hobby_list.dict::update({ hobby_key : prev_Hobby_list + here.id });
                    recorded = 1;
                    //report Hobby_list[hobby_key];
                
                }
                                
            }
            if(recorded == 0){
                //Hobby_list.dict::update({hobby : [here.id]});
                Hobby_list[hobby] = [here.id];
                //report Hobby_list.dict::keys;
            }         
                       
        }
        
    }
    with exit {
        report Hobby_list;
        }

}


walker skill_cluster {
    has skill_list = {};
    has member_skills = [];
    has recorded = 0;
    has prev_skill_list = [];
    
    root: take-->node::family_root;
    family_root: take-->node::person;
    
    person{
    

        member_skills = here.skills;
        for skill in member_skills{
            recorded = 0;
            for skill_key in skill_list.dict::keys {
                if (skill == skill_key) {
                    prev_skill_list = skill_list[skill_key];
                    skill_list.dict::update({ skill_key :  prev_skill_list + [here.id]});
                    recorded = 1;
                }
                                
            }
            if(recorded == 0){
                skill_list[skill] = [here.id];
            }         
                       
        }
        
    }
    with exit {
        report skill_list; 
        }

}
    

walker find_all_cars {
    has anchor car_list = [];
    has anchor cars;


    root: take-->node::family_root;
    family_root: take-->node::person;
    
    person{
        
        cars = here.cars;
        if cars:
            for car in cars:
                if car in car_list:
                    continue;
                else:
                    car_list.list::append(car);
    }
    with exit {
        report car_list;
        }

}

walker possible_blood_donors {
    has blood_group = {"O+":[],"O-":[],"A+":[],"A-":[],"B+":[],"B-":[],"AB+":[],"AB-":[]};
    has member_blood = "";
    has recorded = 0;
    has prev_blood_group_list = [];
    
    root: take-->node::family_root;
    family_root: take-->node::person;
    
    person{
        member_blood = here.blood_group;
        if (member_blood == "O+"){
            for key in ["O+","A+","B+","AB+"]{
                prev_blood_group_list = blood_group[key];
                blood_group.dict::update({ key :  prev_blood_group_list + [here.id]});
            }    
        }

        if (member_blood == "A+"){
            for key in ["A+","AB+"]{
                prev_blood_group_list = blood_group[key];
                blood_group.dict::update({ key :  prev_blood_group_list + [here.id]});
            }    
        }
         if (member_blood == "B+"){
            for key in ["B+","AB+"]{
                prev_blood_group_list = blood_group[key];
                blood_group.dict::update({ key :  prev_blood_group_list + [here.id]});
            }    
        }
         if (member_blood == "AB+"){
            for key in ["AB+"]{
                prev_blood_group_list = blood_group[key];
                blood_group.dict::update({ key :  prev_blood_group_list + [here.id]});
            }    
        }
         if (member_blood == "O-"){
            for key in ["O+","O-","A+","A-","B+","B-","AB+","AB-"]{
                prev_blood_group_list = blood_group[key];
                blood_group.dict::update({ key :  prev_blood_group_list + [here.id]});
            }    
        }
         if (member_blood == "A-"){
            for key in ["A+","A-","AB+","AB-"]{
                prev_blood_group_list = blood_group[key];
                blood_group.dict::update({ key :  prev_blood_group_list + [here.id]});
            }    
        }
         if (member_blood == "B-"){
            for key in ["B+","B-","AB+","AB-"]{
                prev_blood_group_list = blood_group[key];
                blood_group.dict::update({ key :  prev_blood_group_list + [here.id]});
            }    
        }
         if (member_blood == "AB-"){
            for key in ["AB+","AB-"]{
                prev_blood_group_list = blood_group[key];
                blood_group.dict::update({ key :  prev_blood_group_list + [here.id]});
            }    
        } 
        
    }
    with exit {
        report blood_group; 
        }

}
    
