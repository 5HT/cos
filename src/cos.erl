-module(cos).
-compile(export_all).
-behaviour(application).
-behaviour(supervisor).
-include("cos.hrl").
-export([start/2, stop/1, init/1]).

t(X) -> case string:trim(X) of <<>> -> []; A -> A end.

start(_StartType, _StartArgs) -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).
stop(_State) -> ok.
init([]) -> {ok, { {one_for_one, 5, 10}, []} }.

main() ->
  [ begin
      {ok,Sample} = file:read_file(File),
      Lines = string:tokens(binary_to_list(Sample),"\r\n"),
      lists:flatten([ decode(list_to_binary(Line)) || Line <- Lines ])
    end || File <- filelib:wildcard("priv/*.txt") ].

decode(<<Id:2/binary,Type:3/binary,Desc:20/binary,Payer:2/binary,Sender:8/binary,
         Receiver:8/binary,Receiver1:8/binary,Receiver2:8/binary,Receiver3:8/binary,Receiver4:8/binary,
         Time:10/binary,TimeId:1/binary,SenderC:5/binary,
         ReceiverC:5/binary,ReceiverC1:5/binary,ReceiverC2:5/binary,ReceiverC3:5/binary,ReceiverC4:5/binary,
         FileCreator:5/binary,PortCreator:5/binary,
         Rest/binary>>) when Id == <<"00">> ->
  #'COS.00'{id=Id,type=t(Type),desc=t(Desc),payer=t(Payer),sender=t(Sender),
            receivers=[t(Receiver),t(Receiver1),t(Receiver2),t(Receiver3),t(Receiver4)],
            time=Time, time_id=TimeId,sender_c=t(SenderC),
            receivers_c=[t(ReceiverC),t(ReceiverC1),t(ReceiverC2),t(ReceiverC3),t(ReceiverC4)],
            creator=t(FileCreator),creator_c=t(PortCreator)};

decode(<<Id:2/binary,Filler1:3/binary,LineMark:2/binary,Filler2:3/binary,VesselCode:6/binary,
         VesselName:20/binary,Voyage:5/binary,Arrival:6/binary,Sailing:6/binary,ShipNo:15/binary,
         CallSign:6/binary,Rest/binary>>) when Id == <<"11">> ->
  #'COS.11'{id=Id,line_mark=LineMark,vessel_code=t(VesselCode),vessel_name=t(VesselName),
            voyage=Voyage,arrival=Arrival,saling=Sailing,ship=ShipNo,call=CallSign};

decode(<<Id:2/binary,Filler1:3/binary,BLNo:16/binary,SoNo:16/binary,PreCode:6/binary,
         PreName:20/binary,PreVoyage:5/binary,Receipt:5/binary,Loading:5/binary,
         CFS:9/binary,Prepaid:1/binary,Trans:1/binary,Empty:1/binary,
         Date:6/binary,SCNo:12/binary,Quarantine:1/binary,Rest/binary>>) when Id == <<"12">> ->
  #'COS.12'{id=Id,blno=t(BLNo),sono=t(SoNo),pre_code=t(PreCode),pre_name=t(PreName),pre_voyage=t(PreVoyage),
            receipt=t(Receipt),loading=t(Loading),cfs=t(CFS),prepaid=Prepaid,trans=Trans,empty=Empty,
            date=Date,scno=t(SCNo),qua=t(Quarantine)};

decode(<<Id:2/binary,Filler1:3/binary,Discharge:5/binary,DeliveryCode:5/binary,
         DeliveryName:20/binary,FinalCode:5/binary,FinalName:20/binary,
         OID1:1/binary,OIDL1:5/binary,OIDR1:5/binary,
         OID2:1/binary,OIDL2:5/binary,OIDR2:5/binary,
         OID3:1/binary,OIDL3:5/binary,OIDR3:5/binary,
         OID4:1/binary,OIDL4:5/binary,OIDR4:5/binary,
         OID5:1/binary,OIDL5:5/binary,OIDR5:5/binary,
         OID6:1/binary,OIDL6:5/binary,OIDR6:5/binary,
         Rest/binary>>) when Id == <<"13">> ->
  #'COS.13'{id=Id,discharge=t(Discharge),delivery_code=t(DeliveryCode),delivery_name=t(DeliveryName),
            final_code=t(FinalCode),final_name=t(FinalName),options=[
            {t(OID1),t(OIDL1),t(OIDR1)},{t(OID2),t(OIDL2),t(OIDR2)},{t(OID3),t(OIDL3),t(OIDR3)},
            {t(OID4),t(OIDL4),t(OIDR4)},{t(OID5),t(OIDL5),t(OIDR5)},{t(OID6),t(OIDL6),t(OIDR6)}]};

decode(<<Id:2/binary,Filler:3/binary,Code:17/binary,
         Sh1:35/binary,Sh2:35/binary,Sh3:35/binary,Rest/binary>>) when Id == <<"16">> ->
  #'COS.16'{id=Id,code=t(Code),ship={t(Sh1),t(Sh2),t(Sh3)}};

decode(<<Id:2/binary,Filler:3/binary,Code:17/binary,
         Sh1:35/binary,Sh2:35/binary,Sh3:35/binary,Rest/binary>>) when Id == <<"21">> ->
  #'COS.21'{id=Id,code=t(Code),cosigners={t(Sh1),t(Sh2),t(Sh3)}};

decode(<<Id:2/binary,Filler:3/binary,No:1/binary,Code:17/binary,
         Sh1:35/binary,Sh2:35/binary,Sh3:35/binary,Rest/binary>>) when Id == <<"26">> ->
  #'COS.26'{id=Id,code=t(Code),no=No,notify={t(Sh1),t(Sh2),t(Sh3)}};

decode(<<Id:2/binary,Filler:3/binary,No:3/binary,Code:17/binary,
         DG:1/binary,Pkgs:6/binary,Kind:3/binary,Desc:15/binary,
         Gross:9/binary,Net:9/binary,Measure:5/binary,Rest/binary>>) when Id == <<"41">> ->
  #'COS.41'{id=Id,no=No,code=t(Code),dg=DG,pkgs=Pkgs,kind=Kind,desc=t(Desc),gross=Gross,
            net=Net,measure=Measure};

decode(<<Id:2/binary,Filler:3/binary,No:1/binary,CFR1:11/binary,CFR2:11/binary,
         Label1:11/binary,Label2:11/binary,Contact:20/binary,Rest/binary>>) when Id == <<"42">> ->
  #'COS.42'{id=Id,no=No,class={t(CFR1),t(CFR2)},label={t(Label1),t(Label2)},contact=t(Contact)};

decode(<<Id:2/binary,Filler:3/binary,No:3/binary,Class:5/binary,Page:7/binary,UN:4/binary,
         Label1:16/binary,Label2:16/binary,Flash:5/binary,EMS:6/binary,
         Med:4/binary,Pollutant:1/binary,Sign:1/binary,TempFrom:3/binary,
         Sign2:1/binary,TempTo:3/binary,TempId:1/binary,Rest/binary>>) when Id == <<"43">> ->
  #'COS.43'{id=Id,no=No,class=t(Class),page=t(Page),unno=UN,label={t(Label1),t(Label2)},
            flash=t(Flash),ems=EMS,med=t(Med),sign=t(Sign),sign2=t(Sign2),
            temp={t(TempId),t(TempFrom),t(TempTo)}};

decode(<<Id:2/binary,Filler:3/binary,No:3/binary,I1:2/binary,N1:18/binary,I2:2/binary,
         N2:18/binary,I3:2/binary,N3:18/binary,I4:2/binary,N4:18/binary,I5:2/binary,
         N5:18/binary,I6:2/binary,N6:18/binary,Rest/binary>>) when Id == <<"44">> ->
  #'COS.44'{id=Id,no=No,marks=[{t(I1),t(N1)},{t(I2),t(N2)},{t(I3),t(N3)},
                               {t(I4),t(N4)},{t(I5),t(N5)},{t(I6),t(N6)}]};

decode(<<Id:2/binary,Filler:3/binary,No:3/binary,Desc1:30/binary,Desc2:11/binary,
         Desc3:11/binary,Desc4:11/binary,Rest/binary>>) when Id == <<"47">> ->
  #'COS.47'{id=Id,no=No,desc={t(Desc1),t(Desc2),t(Desc3),t(Desc4)}};

decode(<<Id:2/binary,Filler:3/binary,No:3/binary,Container:11/binary,
         Soc:1/binary,Seal:10/binary,Cnt:4/binary,DG:1/binary,
         Status:1/binary,Item:9/binary,Sid:1/binary,Pkgs:6/binary,
         Kind:8/binary,Cargo:5/binary,Tare:5/binary,Measure:5/binary,Loc:6/binary,
         Rest/binary>>) when Id == <<"51">> ->
  #'COS.51'{id=Id,no=t(No),container=t(Container),seal=t(Seal),
            soc=t(Soc),cnt=t(Cnt),dg=t(DG),status=t(Status),item=t(Item),sid=t(Sid),
            packages=t(Pkgs),kind=t(Kind),cargo=t(Cargo),tare=t(Tare),measure=t(Measure),location=t(Loc)};

decode(<<Id:2/binary,Filler:3/binary,No:2/binary,Code:3/binary,Remark:35/binary,
         Payable:5/binary,Quantity:9/binary,Currency:3/binary,Rate:13/binary,Units:4/binary,Amount:3/binary,
         Sign:1/binary,XRate:12/binary,XCurr:3/binary,XAmount1:8/binary,XAmount2:4/binary,XSign:1/binary,Prepaid:1/binary,
         Rest/binary>>) when Id == <<"61">> ->
  #'COS.61'{id=Id,no=t(No),code=t(Code),remark=t(Remark),payable=t(Payable),quantity=t(Quantity),
            currency=t(Currency),rate=t(Rate),units=t(Units),amount=t(Amount),sign=t(Sign),
            xchg_rate=t(XRate),
            xchg_currency=t(XCurr),xchg_amount={t(XAmount1),t(XAmount2)},xchg_sign=t(XSign),prepaid=t(Prepaid)};

decode(<<Id:2/binary,Filler:3/binary,
         R1:35/binary,R2:35/binary,R3:35/binary,Rest/binary>>) when Id == <<"71">> ->
  #'COS.71'{id=Id,remark={t(R1),t(R2),t(R3)}};

decode(<<Id:2/binary,Filler:3/binary,
         R1:35/binary,R2:35/binary,R3:35/binary,Rest/binary>>) when Id == <<"72">> ->
  #'COS.72'{id=Id,remark={t(R1),t(R2),t(R3)}};

decode(<<Id:2/binary,Filler:3/binary,
         R1:56/binary,R2:56/binary,Rest/binary>>) when Id == <<"73">> ->
  #'COS.73'{id=Id,remark={t(R1),t(R2)}};

decode(<<Id:2/binary,Filler:3/binary,Place:5/binary,Date:30/binary,Prepaid:20/binary,Payable:20/binary,Rest/binary>>) when Id == <<"74">> ->
  #'COS.74'{id=Id,place=t(Place),date=t(Date),prepaid=t(Prepaid),payable=t(Payable)};

decode(<<Id:2/binary,Filler:3/binary,Records:5/binary,Rest/binary>>) when Id == <<"99">> ->
  #'COS.99'{id=Id,records=t(Records)};

decode(_) -> [].
