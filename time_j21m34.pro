PRO time_j21m34,p,kindat,p_index,p_daytime
;{

    dayno=p.(kindat).dayno.value(p_index)
    uth=p.(kindat).uth.value(p_index)
    p_daytime=dayno+uth/24.0

;}
END

