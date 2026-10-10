

#let csv_tab(file_path, caption) = {

let data = csv(file_path);
let num_r = data.len();
let num_c = data.at(0).len();

figure(
  table(
    columns: num_c,
    ..data.flatten(),
  ),
  caption: caption
)

}


#let tex2typst(tex_equ_str) = {
  
  let res_str = tex_equ_str.replace(regex("\\\\frac\{(.+?)\}\{(.+?)\}"), "($1)/($2)");
  res_str = res_str.replace("\partial", "diff");

  res_str = res_str.replace(
    regex("\\\\right([\[\]\(\)\{\}])"),
    "$2"
  );
  res_str = res_str.replace(
    regex("\\\\left([\[\]\(\)\{\}])"),
    "$2"
  );

  res_str = res_str.replace(
    "\\",
    ""
  );

  [$ #res_str $]
}


#let where(..args) = {
  let a = args.pos();
  let fn(arg) = arg.join([ -- ]);
  let b = a.chunks(2, exact: true).map(fn);
  [где #b.join([;\ #h(1.25cm) #context h(measure([где\s]).width)]).]
}