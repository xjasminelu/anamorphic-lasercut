

function draw_pts_to(output, pts)

    FF = open(output, "w")
    print(FF, """<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
    width="612pt"
    height="792pt"
    viewBox="0 0 1000 1000">
  <defs>
     <style type="text/css"><![CDATA[
       path {
          fill: none;
       }
     ]]></style>
  </defs>\n""");
      r = 1
      color = "red"
      for i=1:size(pts)[1]
          print(FF, "<circle cx=\"$(pts[i,2]*2)\" cy=\"$(pts[i,1]*2)\" ")
          print(FF, "r=\"$r\" ")
          print(FF, "stroke=\"$color\" fill=\"$color\" ")
          println(FF, "/>")
      end
      print(FF, "</svg>\n")
      close(FF)
end

function svg_beams(FF, pts, mult, offsetX, offsetY)
    color = "red"

    println(FF, "<path style=\"stroke:$color\"\n  d=\"")
    x_1 = pts[1,2]*mult + offsetX
    y_1 = pts[1,1]*mult + offsetY
    println(FF, "M $x_1 $y_1")


    for i=2:size(pts)[1]
        x = pts[i, 2]*mult + offsetX
        y = pts[i, 1]*mult + offsetY
        println(FF, "L $x $y")
    end
    println(FF, "L $x_1 $y_1")
    println(FF, "\"/>")
end

function draw_linepts(output, pts, mult, offsetX, offsetY)

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
      color = "red"

      println(FF, "<path style=\"stroke:$color\"\n  d=\"")
      x_1 = pts[1,2]*mult + offsetX
      y_1 = pts[1,1]*mult + offsetY
      println(FF, "M $x_1 $y_1")


      for i=2:size(pts)[1]
          x = pts[i, 2]*mult + offsetX
          y = pts[i, 1]*mult + offsetY
          println(FF, "L $x $y")
      end
      println(FF, "L $x_1 $y_1")
      println(FF, "\"/>")
      print(FF, "</svg>\n")
      close(FF)
end

function draw_blackpts(output, img)

    FF = open(output, "w")
    print(FF, """<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
    width="612pt"
    height="792pt"
    viewBox="0 0 1000 1000">
  <defs>
     <style type="text/css"><![CDATA[
       path {
          fill: none;
       }
     ]]></style>
  </defs>\n""");
      r = 1
      color = "red"
      for i=1:size(img)[1], j=1:size(img)[2]

          #val = Gray(img[i,j])/0xff
          #if val != 0.0
          if img[i,j] != RGBA{N0f8}(0.0,0.0,0.0,0.0)
              print(FF, "<circle cx=\"$(i*5)\" cy=\"$(j*5)\" ")
              print(FF, "r=\"$r\" ")
              print(FF, "stroke=\"$color\" fill=\"$color\" ")
              println(FF, "/>")
          end
      end
      print(FF, "</svg>\n")
      close(FF)
end
