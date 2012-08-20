def checkUserPasswordChangeNeed(request, user = None):
    if user == None:
        user = request.user
    if request.matched_route != None:
        route_name = request.matched_route.name
        if     user.needs_password_change \
           and route_name != 'settings_me_edit' \
           and route_name.find('static') < 0:
           
           request.session.flash(request.translate(u"You need to change your password."), 'success')
           return True