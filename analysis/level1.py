import os, json  # system functions
from nipype import Workflow, Node
import nipype.interfaces.io as nio  # Data i/o
import nipype.interfaces.fsl as fsl  # fsl
import nipype.interfaces.utility as util  # utility
import nipype.pipeline.engine as pe  # pypeline engine
import nipype.algorithms.modelgen as model  # model generation
from nipype.interfaces.fsl import Level1Design, model
from nipype.algorithms.modelgen import SpecifyModel

# Experiment specific details
bids_dir = "/blue/stevenweisberg/share/DSP_fMRI/"
task = "dspfmri"
subject_list = ["dspfmri11002"]
run_list = ["1", "2", "3", "4"]
tr = 1.5


# Set up the contrasts
contrasts = [
    ["Vid>baseline", "T", ["learning_vid", "control_vid"], [0.5, 0.5]],
    ["Learning>Control", "T", ["learning_vid", "control_vid"], [1, -1]],
    ["Control>Learning", "T", ["learning_vid", "control_vid"], [-1, 1]],
    ["instructions>Baseline", "T", ["instructions"], [1]],
]

# Set FSL details
fsl.FSLCommand.set_default_output_type("NIFTI_GZ")

datasource = pe.Node(
    nio.DataGrabber(
        infields=["subject_id", "run_id"], outfields=["func", "events", "mask"]
    ),
    name="datasource",
)

datasource.inputs.base_directory = bids_dir
datasource.inputs.template = "*"
datasource.inputs.field_template = {
    "func": "derivatives/clean_data/s*/sub-%s_task-dspfmri_run-%s_*mask*",
    "events": "behavioral/Moore_2020/DSP_PsychoPy/onsets/s*/sub-%s_task-dspfmri_run-0%s_events.tsv",
    "mask": "derivatives/s*/func/sub-%s_task-dspfmri_run-%s_space-MNI*brain_mask.nii.gz",
}

datasource.inputs.sort_filelist = True

infosource = pe.Node(
    interface=util.IdentityInterface(fields=["subject_id", "run_id"]), name="infosource"
)

infosource.iterables = [("subject_id", subject_list), ("run_id", run_list)]


# SpecifyModel - Generates Model
modelspec = pe.Node(
    SpecifyModel(input_units="secs", time_repetition=tr, high_pass_filter_cutoff=128.0),
    name="modelspec",
)

# Sets up the fsf file generation
level1design = pe.Node(
    Level1Design(
        interscan_interval=tr,
        bases={"dgamma": {"derivs": True}},
        model_serial_correlations=True,
        contrasts=contrasts,
    ),
    name="level1design",
)


modelgen = pe.MapNode(
    interface=fsl.FEATModel(), name="modelgen", iterfield=["fsf_file", "ev_files"]
)

modelestimate = pe.MapNode(
    interface=fsl.FILMGLS(smooth_autocorr=True),
    name="modelestimate",
    iterfield=["design_file", "in_file", "tcon_file"],
)


copemerge = pe.MapNode(
    interface=fsl.Merge(dimension="t"), iterfield=["in_files"], name="copemerge"
)

varcopemerge = pe.MapNode(
    interface=fsl.Merge(dimension="t"), iterfield=["in_files"], name="varcopemerge"
)

level2model = pe.Node(interface=fsl.L2Model(num_copes=len(run_list),), name="l2model")

flameo = pe.MapNode(
    interface=fsl.FLAMEO(run_mode="flame1"),
    name="flameo",
    iterfield=["cope_file", "var_cope_file"],
)


# Updated here - https://github.com/niflows/nipype1-workflows/blob/master/package/niflow/nipype1/workflows/fmri/fsl/estimate.py#L141
modelfit = pe.Workflow(name="modelfit")
modelfit.connect(
    [
        (modelspec, level1design, [("session_info", "session_info")]),
        (level1design, modelgen, [("fsf_files", "fsf_file"), ("ev_files", "ev_files")]),
        (modelgen, modelestimate, [("design_file", "design_file")]),
        (
            modelgen,
            modelestimate,
            [("con_file", "tcon_file"), ("fcon_file", "fcon_file")],
        ),
    ]
)

within_sub.connect(
    [
        (modelestimate, copemerge, [("copes", "in_files")]),
        (modelestimate, varcopemerge, [("varcopes", "in_files")]),
        (copemerge, flameo, [("merged_file", "cope_file")]),
        (varcopemerge, flameo, [("merged_file", "var_cope_file")]),
        (
            level2model,
            flameo,
            [
                ("design_mat", "design_file"),
                ("design_con", "t_con_file"),
                ("design_grp", "cov_split_file"),
            ],
        ),
    ]
)


l1pipeline = pe.Workflow(name="level1")
l1pipeline.base_dir = os.path.abspath("./fsl/workingdir")
l1pipeline.config = {
    "execution": {"crashdump_dir": os.path.abspath("./fsl/crashdumps")}
}

l1pipeline.connect(
    [
        (infosource, datasource, [("subject_id", "subject_id"), ("run_id", "run_id")]),
        (datasource, modelfit, [("func", "modelestimate.in_file")]),
        (datasource, modelfit, [("events", "modelspec.bids_event_file")]),
        (datasource, modelfit, [("func", "modelspec.functional_runs")]),
        (datasource, modelfit, [("mask", "flameo.mask_file")]),
    ]
)

l1pipeline.write_graph("workflow_graph.dot")
from IPython.display import Image

Image(
    filename="/blue/stevenweisberg/share/DSP_fMRI/code/analysis/fsl/workingdir/level1/workflow_graph.png"
)
# outgraph = l1pipeline.run()
l1pipeline.run(plugin="MultiProc", plugin_args={"n_procs": 4})
