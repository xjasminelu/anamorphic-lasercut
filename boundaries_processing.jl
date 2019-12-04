using FileIO, Colors, Images

include("draw_pts.jl")

function isTransparent(value)
    if value == RGBA{N0f8}(1.0,1.0,1.0,0.0)
        return true
    elseif value == RGBA{N0f8}(0.0,0.0,0.0,0.0)
        return true
    else
        return false
    end
end

#Adapted from https://gist.github.com/cwellsx/e9a1d7092203073c40565455c9b5c79d
function process_arr(arr)
    #Find first pixel where image is not white
    inside = false
    length, width = size(arr)
    arr = padarray(arr, Fill(RGBA{N0f8}(0.0,0.0,0.0,0.0),(1,1),(1,1)))
    b_arr = Array{Float64}(undef, 0, 2)
    lists = Array{Float64}(undef, 0, 2)
    pt_i = 0
    pt_j = 0
    @show arr[1,1]
    for i = 1:size(arr)[1], j = 1:size(arr)[2]
        #arr_val = Gray(arr[i-1,j-1])/0xff
        #if arr_val != 0.0
        if !isTransparent(arr[i-1,j-1])
            pt_i = i
            pt_j = j
            println("PT FOUND $i,$j")
            break
        end
    end
    list = Array{Float64}(undef, 0, 2)
    list = vcat(list, [pt_i pt_j])
    b_arr = vcat(b_arr, [pt_i pt_j])

    checkLocationNr = 1
    startPos = [pt_i pt_j]
    point = [pt_i pt_j]
    counter = 0
    counter2 = 0

    stopcriterion = false
    while !stopcriterion
        checkPosPt, newLocNr = neighbor(point, checkLocationNr)
        if checkPosPt[1]-1 < 0 || checkPosPt[1]-1 >= length || checkPosPt[2]-1 < 0 || checkPosPt[2]-1 >= width
             check_val = 0.0
        else
            check_val = isTransparent(arr[Int(checkPosPt[1])-1,Int(checkPosPt[2])-1]) ? 0.0 : 1.0
        end
        if check_val != 0.0
            #next border pt found
            if checkPosPt == startPos
                counter = counter+1
                if newLocNr == 1 || counter >= 3
                    inside = true
                    stopcriterion = true
                    break
                end
            end
            checkLocationNr = newLocNr
            point = checkPosPt
            counter2 = 0
            list = vcat(list, point)
            b_arr = vcat(b_arr, point)
        else
            checkLocationNr = 1 + (checkLocationNr % 8)
            if counter2 > 8
                counter2 = 0
                stopcriterion = true
                break
            else
                counter2 = counter2+1
            end
        end
    end
    return b_arr
end

function neighbor(pt, num)
    if num == 1
        return [pt[1] - 1.0 pt[2]], 7
    elseif num == 2
        return [pt[1] - 1.0 pt[2] - 1.0], 7
    elseif num == 3
        return [pt[1] pt[2] - 1.0], 1
    elseif num == 4
        return [pt[1]+1.0 pt[2] - 1.0], 1
    elseif num == 5
        return [pt[1]+1.0 pt[2]], 3
    elseif num == 6
        return [pt[1]+1.0 pt[2]+1.0], 3
    elseif num == 7
        return [pt[1] pt[2]+1.0], 5
    elseif num == 8
        return [pt[1]-1.0 pt[2]+1.0], 5
    else
        return NaN, NaN
    end
end

function gen_beam(arr, beam_w, beam_s)
    for j = beam_s:beam_w+beam_s, i=1:size(arr)[1]
        arr[i,j] = RGBA{N0f8}(0.0,0.0,0.0,1.0)
    end
    arr_padded = padarray(arr, Fill(RGBA{N0f8}(0.0,0.0,0.0,0.0),(0,0),(24,0)))
    for j = beam_s:beam_w+beam_s, i=size(arr)[1]+1:size(arr)[1]+24
        arr_padded[i,j] = RGBA{N0f8}(0.0,0.0,0.0,1.0)
    end
    return arr_padded
end

function pts_to_linepts(pts)
    i = 1
    linepts = Array{Float64}(undef, 0, 2)

    while i <= size(pts)[1]
        linepts = vcat(linepts, transpose(pts[i,:]))
        if i + 1 > size(pts)[1]
            break
        end
        # same line in y direction
        if pts[i, 1] == pts[i+1, 1]
            while i + 1 <= size(pts)[1] && pts[i, 1] == pts[i+1, 1]
                i = i + 1
            end
            linepts = vcat(linepts, transpose(pts[i,:]))
        #same line in x direction
        elseif pts[i, 2] == pts[i+1, 2]
            while i + 1 <= size(pts)[1] && pts[i, 2] == pts[i+1, 2]
                i = i + 1
            end
            linepts = vcat(linepts, transpose(pts[i,:]))
        #same line in diag direction
        elseif pts[i, 2]+1 == pts[i+1, 2] && pts[i, 1] + 1 == pts[i+1,1]
            while i + 1 <= size(pts)[1] &&  pts[i, 2] + 1 == pts[i+1, 2] && pts[i, 1] + 1 == pts[i+1,1]
                i = i + 1
            end
            linepts = vcat(linepts, transpose(pts[i,:]))
        end
        i = i + 1
    end
    return linepts
end

function main()
    img = load("imgs/letter-N.png")
    width = size(img)[1]
    div_w = Int(round(width/5))

    beam_w = Int(round(7*div_w/81))
    beam_s = Int(round((div_w - beam_w)/2))

    #Assumes we will only use square images
    arr_1 = gen_beam(img[1:width, 1:div_w], beam_w, beam_s)
    arr_2 = gen_beam(img[1:width, div_w+1:2*div_w], beam_w, beam_s)
    arr_3 = gen_beam(img[1:width, 2*div_w+1:3*div_w], beam_w, beam_s)
    arr_4 = gen_beam(img[1:width, 3*div_w+1:4*div_w], beam_w, beam_s)
    arr_5 = gen_beam(img[1:width, 4*div_w+1:5*div_w], beam_w, beam_s)

    b_pts1 = process_arr(arr_1)
    b_pts2 = process_arr(arr_2)
    b_pts3 = process_arr(arr_3)
    b_pts4 = process_arr(arr_4)
    b_pts5 = process_arr(arr_5)

    line_pts1 = pts_to_linepts(b_pts1)
    line_pts2 = pts_to_linepts(b_pts2)
    line_pts3 = pts_to_linepts(b_pts3)
    line_pts4 = pts_to_linepts(b_pts4)
    line_pts5 = pts_to_linepts(b_pts5)
end

function test_main(output, img)
    width = min(size(img)[1],size(img)[2])
    @show width
    div_w = Int(round(width/5))

    beam_w = Int(round(12*div_w/96))
    beam_s = Int(round((div_w - beam_w)/2))

    #Assumes we will only use square images
    arr_1 = gen_beam(img[1:width, 1:div_w], beam_w, beam_s)
    arr_2 = gen_beam(img[1:width, div_w+1:2*div_w], beam_w, beam_s)
    arr_3 = gen_beam(img[1:width, 2*div_w+1:3*div_w], beam_w, beam_s)
    arr_4 = gen_beam(img[1:width, 3*div_w+1:4*div_w], beam_w, beam_s)
    if 5*div_w > width
        arr_5 = gen_beam(img[1:width, 4*div_w+1:width], beam_w, beam_s)
    else
        arr_5 = gen_beam(img[1:width, 4*div_w+1:5*div_w], beam_w, beam_s)
    end

    b_pts1 = process_arr(arr_1)
    b_pts2 = process_arr(arr_2)
    b_pts3 = process_arr(arr_3)
    b_pts4 = process_arr(arr_4)
    b_pts5 = process_arr(arr_5)

    line_pts1 = pts_to_linepts(b_pts1)
    line_pts2 = pts_to_linepts(b_pts2)
    line_pts3 = pts_to_linepts(b_pts3)
    line_pts4 = pts_to_linepts(b_pts4)
    line_pts5 = pts_to_linepts(b_pts5)

    FF = open(output, "w")
    print(FF, """<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
    width="612pt"
    height="792pt"
    viewBox="0 0 612 792">
  <defs>
     <style type="text/css"><![CDATA[
       path {
          fill: none;
       }
     ]]></style>
  </defs>\n""");
    svg_beams(FF, line_pts1, 96/div_w, 10, 10)
    svg_beams(FF, line_pts2, 96/div_w, 110, 10)
    svg_beams(FF, line_pts3, 96/div_w, 210, 10)
    svg_beams(FF, line_pts4, 96/div_w, 310, 10)
    svg_beams(FF, line_pts5, 96/div_w, 410, 10)

    print(FF, "</svg>\n")
    close(FF)
end

function draw_square(FF, offsetX, offsetY)
    color = "red"
    println(FF, "<path style=\"stroke:$color\"\n  d=\"")
    println(FF, "M $offsetX $offsetY")
    x_d = offsetX + 12
    y_d = offsetY + 12
    println(FF, "L $x_d $offsetY")
    println(FF, "L $x_d $y_d")
    println(FF, "L $offsetX $y_d")
    println(FF, "L $offsetX $offsetY")
    println(FF, "\"/>")
end

function gen_board(output)
    FF = open(output, "w")
    print(FF, """<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
    width="792pt"
    height="792pt"
    viewBox="0 0 792 792">
  <defs>
     <style type="text/css"><![CDATA[
       path {
          fill: none;
       }
     ]]></style>
  </defs>\n""");
    for i=1:5, j=1:5
        draw_square(FF, i*116, j*116)
    end

    for i=1:5, j=1:5
        draw_square(FF, i*116 - 58, j*116 - 58)
    end

    offsetX = 5
    offsetY = 5
    color = "red"
    println(FF, "<path style=\"stroke:$color\"\n  d=\"")
    println(FF, "M $offsetX $offsetY")
    x_d = offsetX + 656
    y_d = offsetY + 656
    println(FF, "L $x_d $offsetY")
    println(FF, "L $x_d $y_d")
    println(FF, "L $offsetX $y_d")
    println(FF, "L $offsetX $offsetY")
    println(FF, "\"/>")

    print(FF, "</svg>\n")
    close(FF)
end


#main()
