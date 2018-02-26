function G = G_factor(w,name,CTV,C5V,D,A)

% open czi files for CTV
path = ['/Users/manzellalapeij/Documents/FRET data/Organized FRET data/seFRET/CTV/',w,'/'];
ctv_stack = bfopen([path,name]);

Ida1 = CTV{2};
Dbt1 = CTV{1}*(D{2}/D{1});
Abt1 = CTV{3}*(A{2}/A{3});

Ida2 = C5V{2};
Dbt2 = C5V{1}*(D{2}/D{1});
Abt2 = C5V{3}*(A{2}/A{3});

Fc1 = Ida1 - Dbt1 - Abt1;
Fc2 = Ida2 - Dbt2 - Abt2;

G = (Fc1/CTV{3} - Fc2/C5V{3})/(C5V{1}/C5V{3} - CTV{1}/CTV{3});



