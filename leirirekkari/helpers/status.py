"""
status key list:
10  - 100 at the camp
110 - 200 out of camp
"""
status_key_list = {
    0 : 'out', # ulkona
    10 : 'at_camp', # leirissa
    30 : 'at_hospital', #
    50 : 'at_program', #
    110 : 'out_coming_back',
    200 : 'out_for_good',
    
}
"""
hospital status key list:
10  - 100 at the hospital
100 - 200 out of camp

"""

hospital_status_key_list = {
    0 : 'out', # ulkona
    10 : 'er', # vastaanotolla
    20 : 'ward', # osastolla
    30 : 'hospital', # osastolla
    110 : 'on_a_way_to_camp', # kotiutuu leiriin
    120 : 'on_a_way_to_home', # kotiutuu kotiin
}