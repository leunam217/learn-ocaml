open Lwt.Infix
open Learnocaml_common
module H = Tyxml_js.Html
open Js_utils
open Learnocaml_data.Exercise.Meta

let token = Learnocaml_data.Token.parse (arg "token") 
module Exercise_link =
  struct
    let exercise_link ?(cl = []) id content =
      let open Tyxml_js.Html5 in
      a ~a:[ a_href ("/description.html#id="^id^"&token="^
                     (Learnocaml_data.Token.to_string token)) ;
             a_class cl ;
        ]
        content
  end
  
module Display = Display_exercise(Exercise_link)    
open Display
       
let _ =
  run_async_with_log @@ fun () ->
     let id = arg "id" in 
     Learnocaml_local_storage.init () ;
     let token = Learnocaml_data.Token.parse (arg "token") in  
     let exercise_fetch =
       retrieve (Learnocaml_api.Exercise (token, id))
     in
     exercise_fetch >>= fun (ex_meta, exo, _deadline) ->

     (* display exercise questions *)
     let text_container = find_component "learnocaml-exo-tab-text" in
     let text_iframe = Dom_html.createIframe Dom_html.document in
     Manip.replaceChildren text_container
       Tyxml_js.Html5.[ h1 [ pcdata ex_meta.title ] ;
                        Tyxml_js.Of_dom.of_iFrame text_iframe ] ;
     Js.Opt.case
       (text_iframe##.contentDocument)
       (fun () -> failwith "cannot edit iframe document")
       (fun d ->
         d##open_;
         d##write (Js.string (exercise_text ex_meta exo));
         d##close) ;
     (* display meta *)
     display_meta token ex_meta id
;;


     
